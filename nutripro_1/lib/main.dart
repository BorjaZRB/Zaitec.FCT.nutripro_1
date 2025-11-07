import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/firebase_options.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }

  runApp(const App());
}
