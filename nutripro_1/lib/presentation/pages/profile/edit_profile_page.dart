import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';
import 'package:nutripro_1/data/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDataLoaded = false;
  late UserProfile _currentProfile;

  final _nameController = TextEditingController();
  final _waterController = TextEditingController();
  final _mealsController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profile = context.watch<UserProfileProvider>().getUserProfileStream(
      user.uid,
    );

    profile.first.then((data) {
      if (data != null && mounted) {
        _currentProfile = data;
        _nameController.text = data.name ?? '';
        _waterController.text = data.waterGoal?.toString() ?? '';
        _mealsController.text = data.mealsPerDay?.toString() ?? '';
        _exerciseController.text = data.exerciseMinutes?.toString() ?? '';
        _weightController.text = data.weight?.toString() ?? '';
        _heightController.text = data.height?.toString() ?? '';

        setState(() {
          _isDataLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _waterController.dispose();
    _mealsController.dispose();
    _exerciseController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no encontrado');

      final profileProvider = context.read<UserProfileProvider>();

      final updatedProfile = _currentProfile.copyWith(
        name: _nameController.text.trim(),
        waterGoal: double.tryParse(_waterController.text.trim()),
        mealsPerDay: int.tryParse(_mealsController.text.trim()),
        exerciseMinutes: int.tryParse(_exerciseController.text.trim()),
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
      );

      await profileProvider.saveUserProfile(user.uid, updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el perfil: $e'),
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
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: !_isDataLoaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _heightController,
                      label: 'Altura (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
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
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
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
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'),
                        ),
                      ],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _mealsController,
                      label: 'Comidas por día',
                      icon: Icons.restaurant,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _exerciseController,
                      label: 'Ejercicio (minutos/día)',
                      icon: Icons.fitness_center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo requerido'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Actualizar Datos'),
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
