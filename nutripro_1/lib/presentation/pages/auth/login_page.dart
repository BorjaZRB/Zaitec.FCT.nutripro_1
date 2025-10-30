// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Spacer(),
                  
                  _buildHeader(),
                  
                  const SizedBox(height: 48),
                  
                  _buildFormContainer(),
                  
                  const SizedBox(height: 16),
                  
                  _buildForgotPasswordLink(),
                  
                  const SizedBox(height: 8),
                  
                  _buildRegisterLink(),
                  
                  const Spacer(),
                  
                  _buildPrivacyPolicy(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Image.asset(
        'assets/images/NutriPro.png',
        width: 500,
        height: 240,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildFormContainer() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.secondary, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 24),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Email',
        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
      ),
      style: TextStyle(color: theme.colorScheme.onSurface),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingresa un email válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Contraseña',
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            splashRadius: 20,
          ),
        ),
      ),
      style: TextStyle(color: theme.colorScheme.onSurface),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildLoginButton() {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Text('Iniciar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildForgotPasswordLink() {
    final theme = Theme.of(context);
    
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad pendiente')),
          );
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    final theme = Theme.of(context);
    
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes cuenta? ',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: Text(
              'Regístrate',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    final theme = Theme.of(context);
    
    return Center(
      child: Text(
        'Política de privacidad | cookies',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login exitoso (simulado)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}