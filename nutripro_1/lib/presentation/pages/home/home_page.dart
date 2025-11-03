
import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/theme_provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // ir al login 
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        // Botón logout 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _logout(context),
          ),
          Builder(
            builder: (ctx) {
              final isDark = ctx.watch<ThemeProvider>().isDarkMode;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro',
                onPressed: () => ctx.read<ThemeProvider>().toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'home',
          style: TextStyle(
            fontSize: 24,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
