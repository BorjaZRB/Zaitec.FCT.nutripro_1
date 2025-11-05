import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/firebase_options.dart';
import 'presentation/app.dart';
import 'services/notification_service.dart';

Future<void> _connectToEmulators() async {
  // En Android Emulator, 'localhost' del PC es 10.0.2.2
  const host = '10.0.2.2';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);

  // Opcional: evita confusiones logueándote anónimo en local
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // SOLO en debug usamos emuladores
  if (kDebugMode) {
    await _connectToEmulators();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  runApp(const App());
}
