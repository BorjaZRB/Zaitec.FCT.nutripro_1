import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutripro',
      theme: appThemeLight, // 👈 tema global
      debugShowCheckedModeBanner: false,
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    // Demo rápida para validar colores
    return Scaffold(
      appBar: AppBar(title: const Text('Nutripro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Texto principal',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Texto secundario',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Continuar')),
          ],
        ),
      ),
    );
  }
}
