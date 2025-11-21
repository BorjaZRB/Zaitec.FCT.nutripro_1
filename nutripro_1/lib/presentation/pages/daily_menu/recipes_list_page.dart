import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/config/image_hosts.dart';
import 'package:nutripro_1/presentation/pages/daily_menu/recipes_detail_page.dart';
import 'package:nutripro_1/presentation/widgets/net_image.dart';

class RecipesListPage extends StatelessWidget {
  const RecipesListPage({super.key});

  // Demo: datos locales. Si luego quieres, los lees de Firestore.
  static const items = [
    {'id': 'r1', 'name': 'Paella',   'file': 'paella.jpg'},
    {'id': 'r2', 'name': 'Tortilla', 'file': 'tortilla.jpg'},
    {'id': 'r3', 'name': 'Gazpacho', 'file': 'gazpacho.jpg'},
    {'id': 'r4', 'name': 'Ensalada', 'file': 'Ensalada.jpg'},
    {'id': 'r5', 'name': 'Plato combinado', 'file': 'Platocombinado.jpg'},
    {'id': 'r6', 'name': 'Yogur', 'file': 'yogur.jpg'},
    {'id': 'r7', 'name': 'Fruta', 'file': 'Fruta.jpg'},
    {'id': 'r8', 'name': 'Pollo', 'file': 'Pollo.jpg'},
    {'id': 'r9', 'name': 'Carne Roja', 'file': 'Carneroja.jpg'},


  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final r = items[i];
          final url = '${ImageHosts.base}${r['file']}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: NetImage(url,
              width: 72, height: 72, radius: BorderRadius.circular(12), heroTag: r['id']),
            title: Text(r['name']!),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailPage(
                  id: r['id']!, name: r['name']!, imageUrl: url,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
