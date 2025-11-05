import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/firebase_options.dart';
import 'presentation/app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  runApp(const App());
}
