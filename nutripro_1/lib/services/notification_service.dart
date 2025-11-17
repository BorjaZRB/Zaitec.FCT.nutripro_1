import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio. Si se pasa [navigatorKey], se usará para
  /// navegar cuando el usuario pulse una notificación.
  Future<void> init(GlobalKey<NavigatorState>? navigatorKey) async {
    // 1. Inicializar Timezone (Obligatorio para zonedSchedule)
    tz.initializeTimeZones();

    // Obtener la implementación de Android para tareas específicas
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // NOTA: No solicitamos permisos de Android aquí para evitar mostrar
    // el diálogo antes de que la UI esté lista. Use requestPermissions()
    // desde la UI o tras runApp.

    // === CREACIÓN DE CANALES ANDROID ===

    // Canal 1: Diario (para scheduleDailyReminder)
    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'daily_channel',
      'Recordatorios Diarios NutriPro',
      description: 'Canal para recordatorios de comidas a horas fijas.',
      importance: Importance.max,
    );
    await androidImpl?.createNotificationChannel(dailyChannel);

    // Canal 2: Horario (para scheduleHourlyReminder)
    const AndroidNotificationChannel hourlyChannel = AndroidNotificationChannel(
      'hourly_channel',
      'Recordatorio de Hidratación',
      description: 'Recordatorios que se repiten cada hora.',
      importance: Importance.low,
    );
    await androidImpl?.createNotificationChannel(hourlyChannel);

    // Canal 3: Alta importancia 
    const AndroidNotificationChannel highChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificaciones Importantes',
      description: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.max,
    );
    await androidImpl?.createNotificationChannel(highChannel);

    // === INICIALIZACIÓN DEL PLUGIN ===
  // Forzar uso explícito del icono de la app (mipmap/ic_launcher).
  // Usar el recurso con prefijo @mipmap para asegurar que se resuelva.
  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Registrar handler para respuesta a notificaciones (tap)
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Si hay un navigatorKey y la app está lista, navegar a /reminders
        try {
          if (navigatorKey?.currentState != null) {
            navigatorKey!.currentState!.pushNamed('/reminders');
          }
        } catch (_) {
          // Silenciar errores de navegación si la app no está lista aún
        }
      },
    );
  }

  /// Guarda el estado de que el usuario ha aceptado permisos de notificación
  Future<void> setNotificationsAccepted(bool accepted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_accepted', accepted);
    } catch (e) {
      debugPrint('Error al guardar estado de permisos: $e');
    }
  }

  /// Devuelve true si el usuario ya aceptó los permisos de notificación
  Future<bool> isNotificationsAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_accepted') ?? false;
    } catch (e) {
      debugPrint('Error al leer estado de permisos: $e');
      return false;
    }
  }

  /// Solicita permisos en Android (Android 13+). Llamar esto desde la UI
  /// después de que `runApp` haya sido llamado (p. ej. en initState o
  /// dentro de un post frame callback) para evitar que el diálogo de
  /// permisos aparezca antes de que la app esté visible.
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  /// Mostrar una notificación simple
  Future<void> showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            'Notificaciones Importantes',
            channelDescription: 'Este canal se usa para notificaciones importantes.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            // Forzar icono válido (usa el mipmap de la app).
            icon: '@mipmap/ic_launcher',
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
    } catch (e, st) {
      // Loggear error para diagnóstico; evita que la app crashee.
      debugPrint('Error showing notification: $e\n$st');
    }
  }

  /// Programa una notificación que se repite a la misma hora todos los días
  Future<void> scheduleDailyReminder(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    // Calcular la próxima hora de ejecución
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Si ya pasó la hora, programar para mañana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'daily_channel',
            'Recordatorios Diarios NutriPro',
            channelDescription: 'Recordatorios diarios de comidas para NutriPro.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // payload usado para identificar que debe abrir la pantalla de recordatorios
        payload: 'reminders',
      );
    } catch (e, st) {
      debugPrint('Error scheduling daily reminder (id=$id): $e\n$st');
    }
  }

  /// Programa una notificación que se repite cada hora
  Future<void> scheduleHourlyReminder() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'hourly_channel',
            'Recordatorio de Hidratación',
            channelDescription: 'Recordatorios que se repiten cada hora.',
            importance: Importance.low,
            priority: Priority.low,
            icon: '@mipmap/ic_launcher',
          );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.periodicallyShow(
        200,
        '¡Bebe Agua!',
        'Recordatorio para mantenerte hidratado.',
        RepeatInterval.hourly,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'reminders',
      );
    } catch (e, st) {
      debugPrint('Error scheduling hourly reminder: $e\n$st');
    }
  }

  /// Devuelve la información sobre si la app fue lanzada desde una notificación
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  /// Solicita permiso de notificaciones (Android 13+ e iOS).
  /// Llama a esto DESPUÉS de que la UI esté lista (ej. tras runApp).
  Future<void> requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Solicitar permiso POST_NOTIFICATIONS en Android 13+
    if (androidImpl != null) {
      try {
        await androidImpl.requestNotificationsPermission();
      } catch (e) {
        // Silenciar errores si el permiso ya fue denegado o no es aplicable
      }
    }
  }

  /// Guarda los recordatorios en SharedPreferences
  Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(reminders);
      await prefs.setString('reminders', jsonString);
    } catch (e) {
      debugPrint('Error al guardar recordatorios: $e');
    }
  }

  /// Carga los recordatorios desde SharedPreferences
  Future<List<Map<String, dynamic>>> loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('reminders');
      
      if (jsonString == null) {
        return []; // No hay recordatorios guardados
      }
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (e) {
      debugPrint('Error al cargar recordatorios: $e');
      return [];
    }
  }

  /// Cancela una notificación programada por ID
  Future<void> cancel(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error al cancelar notificación $id: $e');
    }
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error al cancelar todas las notificaciones: $e');
    }
  }

  /// Devuelve la lista de notificaciones pendientes (para debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final list = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return list;
    } catch (e) {
      debugPrint('Error al obtener pending notifications: $e');
      return [];
    }
  }
}