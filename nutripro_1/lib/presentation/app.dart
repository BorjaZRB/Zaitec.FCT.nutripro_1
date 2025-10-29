import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'pages/auth/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutripro',
      theme: appThemeLight, // 👈 tema global
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // 👈 Mostrando LoginPage temporalmente
    );
  }
}
