import 'package:flutter/material.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/recommendation_provider.dart';
import 'package:nutripro_1/data/providers/tracking_provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/presentation/pages/auth/auth_wrapper.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/providers/theme_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),

        Provider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Nutripro',
            debugShowCheckedModeBanner: false,
            theme: appThemeLight,
            darkTheme: appThemeDark,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}