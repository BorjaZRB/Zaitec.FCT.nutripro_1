
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/services/firestore_service.dart';
import 'package:nutripro_1/presentation/pages/auth/login_page.dart';
import 'package:nutripro_1/presentation/pages/home/recipes_list_page.dart';
import 'package:nutripro_1/presentation/widgets/dashboard_widget.dart';
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
  final _fs = FirestoreService();
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      _fs.createDashboardFromSurvey(user!.uid).catchError((_) {});
    
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    if (!mounted) return;

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

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final stream = _fs.streamUserDocument(user!.uid).map((snap) => snap.data());

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
                  MaterialPageRoute(builder: (context) => const ConfPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Probar Notificación'),
              leading: const Icon(Icons.notification_add_outlined),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);

                try {
                  final NotificationService notificationService =
                      NotificationService();

                  await notificationService.init();
                  await notificationService.showNotification(
                    '¡Prueba de Notificación!',
                    '¡Genial! La Tarea MSG-002 funciona.',
                  );

                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('¡Notificación enviada!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

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
              onTap: _logout,
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
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: stream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data ?? {};

         
          final weekly = (data['weeklyData'] is List)
              ? List<double>.from((data['weeklyData'] as List).map((e) => (e as num).toDouble()))
              : <double>[];
          final monthly = (data['monthlyData'] is List)
              ? List<double>.from((data['monthlyData'] as List).map((e) => (e as num).toDouble()))
              : <double>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DashboardWidget(
                  calories: (data['calories'] ?? 0) as int,
                  meals: (data['meals'] ?? 0) as int,
                  water: ((data['water'] ?? 0) as num).toDouble(),
                  goalsProgress: ((data['goalsProgress'] ?? 0) as num).toDouble(),
                  weeklyData: weekly,
                  monthlyData: monthly,
                ),
                const SizedBox(height: 20),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 24,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipesListPage()),
                    );
                  },
                  child: const Text('Ver recetas'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
