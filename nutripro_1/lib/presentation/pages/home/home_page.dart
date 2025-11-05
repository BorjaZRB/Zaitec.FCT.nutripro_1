import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/theme_provider.dart';
import '../config/conf_page.dart';
import '../profile/profile_page.dart';
import 'package:nutripro_1/services/notification_service.dart';

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
    final imagePath = context.watch<ThemeProvider>().isDarkMode
        ? 'assets/images/NutriProDark.png'
        : 'assets/images/NutriPro.png';

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Image.asset(imagePath, width: 200, fit: BoxFit.contain),
              ),
            ),
            ListTile(
              title: const Text('Perfil'),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Probar Notificación'),
              leading: const Icon(Icons.notification_add_outlined),
              onTap: () async {
                // Cerramos el menú
                Navigator.pop(context);

                // Mostramos la notificación
                final NotificationService notificationService =
                    NotificationService();

                await notificationService.showNotification(
                  '¡Prueba de Notificación!',
                  '¡Genial! La Tarea MSG-002 funciona.',
                );
              },
            ),
            const Spacer(),
            ListTile(
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Inicio'),
      ),
      body: Center(
        child: Text(
          'home',
          style: TextStyle(fontSize: 24, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}
