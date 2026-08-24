import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      username: _usernameController.text.trim(),
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.deepWine),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Crea tu Usuario',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.deepWine,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(),

                    const SizedBox(height: 8),

                    Text(
                      'Empieza la aventura con la persona que amas',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 30),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Usuario',
                        hintText: 'Ej. gabriel, sofia_amor',
                        prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.primaryRose),
                      ),
                      validator: (val) => val != null && val.trim().length >= 3 ? null : 'Mínimo 3 caracteres',
                    ),

                    const SizedBox(height: 14),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Tu Nombre real (opcional)',
                        hintText: 'Ej. Gabriel',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Nickname / Apodo cariñoso
                    TextFormField(
                      controller: _nicknameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apodo cariñoso (ej. Mi Amor, Bebé)',
                        prefixIcon: Icon(Icons.favorite_border_rounded, color: AppTheme.primaryRose),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                      ),
                      validator: (val) => val != null && val.length >= 6 ? null : 'Mínimo 6 caracteres',
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Registrarme e Ingresar 💕',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
