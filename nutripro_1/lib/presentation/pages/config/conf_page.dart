import 'package:flutter/material.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/theme_provider.dart';
import 'package:nutripro_1/presentation/pages/profile/edit_profile_page.dart';
import 'package:provider/provider.dart';
import '../reminders_page.dart';

class ConfPage extends StatelessWidget {
  const ConfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Perfil'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.notifications_active_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Recordatorios'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RemindersPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              await authProvider.signOut();
            },
          ),
          // Aquí puedes agregar más opciones de configuración
        ],
      ),
    );
  }
}
