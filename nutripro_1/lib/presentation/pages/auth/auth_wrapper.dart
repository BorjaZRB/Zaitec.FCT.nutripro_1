import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_home_page.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:nutripro_1/presentation/pages/home/home_page.dart';
import 'package:nutripro_1/presentation/pages/onboarding/onboarding_page.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          return _ProfileLoaderRedirector(
            key: ValueKey(authSnapshot.data!.uid),
            user: authSnapshot.data!,
          );
        }

        return const LoginPage();
      },
    );
  }
}
class _ProfileLoaderRedirector extends StatefulWidget {
  const _ProfileLoaderRedirector({super.key, required this.user});
  final User user;

  @override
  State<_ProfileLoaderRedirector> createState() =>
      _ProfileLoaderRedirectorState();
}

class _ProfileLoaderRedirectorState extends State<_ProfileLoaderRedirector> {
  late final Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = context
        .read<UserProfileProvider>()
        .getUserProfileStream(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (profileSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error al cargar el perfil.')),
          );
        }

        final userProfile = profileSnapshot.data;
        if (userProfile != null && userProfile.isAdmin) {
          return const AdminHomePage();
        }
        if (userProfile == null || userProfile.profileCompleted == false) {
          return const OnboardingPage();
        }
        return const HomePage();
      },
    );
  }
}