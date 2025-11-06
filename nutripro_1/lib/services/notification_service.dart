import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // 1. Instancia del plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 2. Método para INICIALIZAR el servicio y crear canales
  Future<void> init() async {
    // Configuración de inicialización para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'ic_launcher',
        ); // Usa el icono por defecto de Android

    // Creación del Canal de Notificación
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Notificaciones Importantes', // nombre (visible al usuario)
      description:
          'Este canal se usa para notificaciones importantes.', // descripción
      importance: Importance.max, // Prioridad Máxima
    );

    // Registramos el canal en el sistema
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Configuración de inicialización (general)
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          // (Aquí se añadiría la configuración de iOS/macOS si se necesitara)
        );

    // Inicializamos el plugin
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 3. Método para MOSTRAR una notificación
  Future<void> showNotification(String title, String body) async {
    // Detalles específicos de la notificación para Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel', // El ID del canal (debe ser el mismo)
          'Notificaciones Importantes', // El nombre del canal
          channelDescription:
              'Este canal se usa para notificaciones importantes.',
          importance: Importance.max, // Prioridad
          priority: Priority.high,
          ticker: 'ticker',
        );

    // Detalles generales de la notificación
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Mostramos la notificación
    await _flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación (puedes cambiarlo)
      title, // Título
      body, // Cuerpo
      notificationDetails,
    );
  }
}
