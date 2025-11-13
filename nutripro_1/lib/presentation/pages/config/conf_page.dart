import 'package:flutter/material.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/theme_provider.dart';
import 'package:nutripro_1/presentation/pages/profile/edit_profile_page.dart';
import 'package:nutripro_1/presentation/pages/reminders_page.dart';
import 'package:provider/provider.dart';

class ConfPage extends StatelessWidget {
  const ConfPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await context.read<AuthProvider>().signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Editar Perfil'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Recordatorios'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RemindersPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              _signOut(context);
            },
          ),
        ],
      ),
    );
  }
}