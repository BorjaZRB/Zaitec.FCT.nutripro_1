import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/theme_provider.dart';
import '../config/conf_page.dart';
import '../profile/profile_page.dart';
import 'package:nutripro_1/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> _logout() async {
    // Capturamos el Navigator antes de operaciones async
    final navigator = Navigator.of(context);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // Verificar que el widget sigue montado antes de navegar
    if (!mounted) return;

    // ir al login usando el navigator capturado
    navigator.pushAndRemoveUntil(
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
                // Capturamos el ScaffoldMessenger antes de operaciones async
                final messenger = ScaffoldMessenger.of(context);
                
                // Cerramos el menú
                Navigator.pop(context);

                try {
                  // Inicializamos y mostramos la notificación
                  final NotificationService notificationService =
                      NotificationService();
                  
                  // Inicializamos el servicio
                  await notificationService.init();
                  
                  // Mostramos la notificación
                  await notificationService.showNotification(
                    '¡Prueba de Notificación!',
                    '¡Genial! La Tarea MSG-002 funciona.',
                  );
                  
                  // Verificar que el widget sigue montado antes de mostrar el SnackBar
                  if (!mounted) return;
                  
                  // Mostramos un mensaje de confirmación usando el messenger capturado
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('¡Notificación enviada!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  // Verificar que el widget sigue montado antes de mostrar el error
                  if (!mounted) return;
                  
                  // Si hay error, mostramos un mensaje usando el messenger capturado
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al enviar notificación: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
            const Spacer(),
            ListTile(
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              onTap: () => _logout(),
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
