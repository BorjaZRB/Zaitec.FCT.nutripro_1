import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/pages/daily_menu/recipes_list_page.dart';

class DailyMenuPage extends StatelessWidget {
  const DailyMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Menú Diario',
            style: TextStyle(fontSize: 24, color: theme.colorScheme.onSurface),
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
  }
}
