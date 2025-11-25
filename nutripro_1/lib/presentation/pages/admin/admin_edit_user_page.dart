import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class AdminEditUserPage extends StatefulWidget {
  final String userId;
  final UserProfile userProfile;

  const AdminEditUserPage({
    super.key,
    required this.userId,
    required this.userProfile,
  });

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _waterController;
  late final TextEditingController _mealsController;
  late final TextEditingController _calorieGoalController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userProfile.name ?? '',
    );
    _waterController = TextEditingController(
      text: widget.userProfile.waterGoal?.toString() ?? '',
    );
    _mealsController = TextEditingController(
      text: widget.userProfile.mealsPerDay?.toString() ?? '',
    );
    _calorieGoalController = TextEditingController(
      text: widget.userProfile.calorieGoal?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.userProfile.weight?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.userProfile.height?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waterController.dispose();
    _mealsController.dispose();
    _calorieGoalController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final profileProvider = context.read<UserProfileProvider>();

      final updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text.trim(),
        waterGoal: double.tryParse(_waterController.text.trim()),
        mealsPerDay: int.tryParse(_mealsController.text.trim()),
        calorieGoal: int.tryParse(_calorieGoalController.text.trim()),
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
      );

      await profileProvider.saveUserProfile(widget.userId, updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el usuario: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nombre',
                icon: Icons.person,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _heightController,
                label: 'Altura (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _weightController,
                label: 'Peso (kg)',
                icon: Icons.monitor_weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _waterController,
                label: 'Meta de agua (Litros/día)',
                icon: Icons.water_drop,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _mealsController,
                label: 'Comidas por día',
                icon: Icons.restaurant,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _calorieGoalController,
                label: 'Calorías objetivo (kcal/día)',
                icon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _updateUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.secondary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}
