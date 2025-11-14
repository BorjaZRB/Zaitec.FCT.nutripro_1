import 'package:flutter/material.dart';
import 'package:nutripro_1/data/providers/auth_provider.dart';
import 'package:nutripro_1/data/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AdminConfigTab extends StatelessWidget {
  const AdminConfigTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Sección de Apariencia ---
        Text(
          'Apariencia',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: SwitchListTile(
            title: const Text('Modo Oscuro'),
            subtitle: Text(
                themeProvider.isDarkMode == ThemeMode.dark ? 'Activado' : 'Desactivado'),
            secondary: Icon(themeProvider.isDarkMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ),
        
        const Divider(height: 32),

        // --- Sección de Cuenta ---
        Text(
          'Cuenta',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () async {
              // Confirmación antes de salir
              final bool? didConfirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content:
                      const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Salir'),
                    ),
                  ],
                ),
              );

              if (didConfirm == true && context.mounted) {
                await context.read<AuthProvider>().signOut();
              }
            },
          ),
        ),
      ],
    );
  }
}