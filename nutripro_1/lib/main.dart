import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/firebase_options.dart';
import 'presentation/app.dart';
import 'package:nutripro_1/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase init error: $e');
  }

  // Inicializar notificaciones en background (sin bloquear la UI)
  _initializeNotifications();

  runApp(const App());
}

/// Inicializa notificaciones en background sin bloquear la UI principal.
void _initializeNotifications() {
  Future.microtask(() async {
    try {
      final NotificationService notificationService = NotificationService();
      
      // 1. Inicializar el servicio
      await notificationService.init(null);
      
      // 2. Solicitar permisos (sin esperar bloqueante)
      await notificationService.requestNotificationPermissions();
      
      // 3. Programar recordatorios de prueba
      await notificationService.scheduleDailyReminder(
        300,
        'Recuerda tu Snack',
        'Es hora de tu porción de fruta o nueces.',
        14,
        30,
      );
      await notificationService.scheduleHourlyReminder();
      
      print('✓ Notificaciones inicializadas correctamente');
    } catch (e) {
      print('⚠ Error al inicializar notificaciones: $e');
    }
  });
}