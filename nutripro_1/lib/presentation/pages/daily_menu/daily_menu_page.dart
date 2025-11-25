import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/data/mock_data/mock_recipes.dart';
import 'package:nutripro_1/presentation/pages/daily_menu/recipes_detail_page.dart';
import 'package:nutripro_1/presentation/widgets/net_image.dart';

class DailyMenuPage extends StatelessWidget {
  const DailyMenuPage({super.key});

  List<String> _getMealSections(int mealsPerDay) {
    switch (mealsPerDay) {
      case 2:
        return ['Comida', 'Cena'];
      case 3:
        return ['Desayuno', 'Comida', 'Cena'];
      case 4:
        return ['Desayuno', 'Comida', 'Merienda', 'Cena'];
      case 5:
        return ['Desayuno', 'Almuerzo', 'Comida', 'Merienda', 'Cena'];
      default:
        return ['Desayuno', 'Comida', 'Cena']; // Default to 3
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileProvider>().userProfile;
    final mealsPerDay = userProfile?.mealsPerDay ?? 3;
    final sections = _getMealSections(mealsPerDay);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menú Diario'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          final recipes = mockRecipes[section] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  section,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 220, // Height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: recipes.length,
                  itemBuilder: (context, recipeIndex) {
                    final recipe = recipes[recipeIndex];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailPage(
                              id: recipe.id,
                              name: recipe.name,
                              imageUrl: recipe.imageUrl,
                              ingredients: recipe.ingredients,
                              preparation: recipe.preparation,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NetImage(
                                recipe.imageUrl,
                                width: 160,
                                height: 160, // Square image
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
