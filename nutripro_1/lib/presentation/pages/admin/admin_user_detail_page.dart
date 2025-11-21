import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:nutripro_1/presentation/pages/admin/admin_edit_user_page.dart';
import 'package:nutripro_1/presentation/widgets/dashboard_widget.dart';
import 'package:provider/provider.dart';

class AdminUserDetailPage extends StatelessWidget {
  final String userId;
  final UserProfile userProfile;

  const AdminUserDetailPage({
    super.key,
    required this.userId,
    required this.userProfile,
  });

  Future<void> _deleteUser(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el usuario ${userProfile.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final userProfileProvider = context.read<UserProfileProvider>();
        await userProfileProvider.deleteUserProfile(userId);

        // Eliminar también de Firebase Auth
        // Nota: Esto requeriría privilegios de admin en Firebase
        // Por ahora solo eliminamos de Firestore

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar usuario: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _editUser(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AdminEditUserPage(userId: userId, userProfile: userProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile.name ?? 'Usuario'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editUser(context);
              } else if (value == 'delete') {
                _deleteUser(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email, 'Email', userProfile.email),
                    _buildInfoRow(
                      Icons.person,
                      'Nombre',
                      userProfile.name ?? 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.height,
                      'Altura',
                      userProfile.height != null
                          ? '${userProfile.height} cm'
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.monitor_weight,
                      'Peso',
                      userProfile.weight != null
                          ? '${userProfile.weight} kg'
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.water_drop,
                      'Meta de Agua',
                      userProfile.waterGoal != null
                          ? '${userProfile.waterGoal} L/día'
                          : 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.restaurant,
                      'Comidas/día',
                      userProfile.mealsPerDay?.toString() ?? 'N/A',
                    ),
                    _buildInfoRow(
                      Icons.fitness_center,
                      'Ejercicio',
                      userProfile.exerciseMinutes != null
                          ? '${userProfile.exerciseMinutes} min/día'
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Dashboard de progreso
            Text('Progreso', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            // Por ahora mostramos datos de ejemplo
            // En una implementación real, deberías cargar los datos reales del usuario
            DashboardWidget(
              calories: 2000,
              meals: userProfile.mealsPerDay ?? 3,
              water: userProfile.waterGoal ?? 2.0,
              goalsProgress: 0.7,
              weeklyData: [50.0, 60.0, 55.0, 70.0, 65.0, 75.0, 80.0],
              monthlyData: [60.0, 70.0, 65.0, 80.0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
