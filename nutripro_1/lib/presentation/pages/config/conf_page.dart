import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/theme_provider.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Apariencia',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              context.watch<ThemeProvider>().isDarkMode 
                  ? Icons.dark_mode 
                  : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Tema'),
            trailing: Switch(
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (_) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
          const Divider(),
          // Aquí puedes añadir más configuraciones siguiendo el mismo patrón
        ],
      ),
    );
  }
}