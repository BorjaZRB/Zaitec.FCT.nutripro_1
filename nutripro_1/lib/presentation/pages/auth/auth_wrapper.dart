import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:nutripro_1/presentation/pages/home/home_page.dart';
import 'package:nutripro_1/presentation/pages/onboarding/onboarding_page.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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
          final user = authSnapshot.data!;

          return StreamBuilder<UserProfile?>(
            stream: context.read<UserProfileProvider>().getUserProfileStream(
              user.uid,
            ),
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

              if (userProfile == null ||
                  userProfile.profileCompleted == false) {
                return const OnboardingPage();
              }
              return const HomePage();
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}
