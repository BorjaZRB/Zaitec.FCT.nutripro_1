import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/firebase_options.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // En caso de error con Firebase, la app podría no funcionar correctamente
    // En un entorno de producción, aquí se usaría un sistema de logging apropiado
  }
  
  runApp(const App());
}
