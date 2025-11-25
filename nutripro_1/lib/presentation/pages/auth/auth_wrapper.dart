import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_home_page.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:nutripro_1/presentation/pages/home/home_page.dart';
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
  StreamSubscription<UserProfile?>? _subscription;

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserProfileProvider>();
    _subscription = provider
        .getUserProfileStream(widget.user.uid)
        .listen(
          (profile) {
            if (mounted) {
              provider.setUserProfile(profile);
            }
          },
          onError: (error) {
            debugPrint('Error loading profile: $error');
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;

    if (userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProfile.isAdmin) {
      return const AdminHomePage();
    }
    return const HomePage();
  }
}
