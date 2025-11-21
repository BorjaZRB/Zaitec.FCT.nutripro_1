import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRegisterTab extends StatelessWidget {
  const AdminRegisterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: _RegisterUserForm(),
            ),
          ),
        );
      },
    );
  }
}

class _RegisterUserForm extends StatefulWidget {
  const _RegisterUserForm();

  @override
  State<_RegisterUserForm> createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<_RegisterUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waterController = TextEditingController();
  final _mealsController = TextEditingController();
  final _exerciseController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Las contraseñas no coinciden.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Genera un nombre único para la app temporal
    String tempAppName =
        'tempRegister-${DateTime.now().millisecondsSinceEpoch}';

    try {
      // 1. Inicializa una app de Firebase temporal
      firebase_core.FirebaseApp tempApp =
          await firebase_core.Firebase.initializeApp(
            name: tempAppName,
            options: firebase_core.Firebase.app().options,
          );

      // 2. Crea una instancia de Auth solo para esa app temporal
      FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      // 3. Crea el usuario en la instancia temporal
      UserCredential userCredential = await tempAuth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 4. Crea el perfil de usuario en Firestore con TODOS los datos
      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': userCredential.user!.email,
          'name': _nameController.text.trim(),
          'height': double.tryParse(_heightController.text.trim()),
          'weight': double.tryParse(_weightController.text.trim()),
          'waterGoal': double.tryParse(_waterController.text.trim()),
          'mealsPerDay': int.tryParse(_mealsController.text.trim()),
          'exerciseMinutes': int.tryParse(_exerciseController.text.trim()),
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': false,
        });
      }

      // 5. Elimina la app temporal
      await tempApp.delete();

      debugPrint('Registro exitoso por admin');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuario ${_emailController.text} registrado exitosamente.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar formulario
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _nameController.clear();
        _heightController.clear();
        _weightController.clear();
        _waterController.clear();
        _mealsController.clear();
        _exerciseController.clear();
      }
    } catch (e) {
      debugPrint('Error en registro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // Asegúrate de eliminar la app temporal también si hay un error
      try {
        firebase_core.FirebaseApp tempApp = firebase_core.Firebase.app(
          tempAppName,
        );
        await tempApp.delete();
      } catch (e) {
        debugPrint('Error al limpiar app temporal: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _waterController.dispose();
    _mealsController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campo de Email ---
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.contains('@')) {
                    return 'Por favor, introduce un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Contraseña ---
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Confirmar Contraseña ---
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Datos del Perfil', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              // --- Campo de Nombre ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Altura ---
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Altura (cm)',
                  prefixIcon: Icon(Icons.height, color: colorScheme.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Peso ---
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(
                    Icons.monitor_weight,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Meta de Agua ---
              TextFormField(
                controller: _waterController,
                decoration: InputDecoration(
                  labelText: 'Meta de agua (Litros/día)',
                  prefixIcon: Icon(
                    Icons.water_drop,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Comidas por Día ---
              TextFormField(
                controller: _mealsController,
                decoration: InputDecoration(
                  labelText: 'Comidas por día',
                  prefixIcon: Icon(
                    Icons.restaurant,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- Campo de Ejercicio ---
              TextFormField(
                controller: _exerciseController,
                decoration: InputDecoration(
                  labelText: 'Ejercicio (minutos/día)',
                  prefixIcon: Icon(
                    Icons.fitness_center,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.secondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // --- Botón de Registro ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Registrar Usuario'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
