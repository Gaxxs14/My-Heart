import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Quick Start Controllers
  final _quickNameController = TextEditingController();
  final _quickNicknameController = TextEditingController();

  // Quick Link Controllers
  final _linkNameController = TextEditingController();
  final _linkNicknameController = TextEditingController();
  final _linkCodeController = TextEditingController();

  // Classic Login Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quickNameController.dispose();
    _quickNicknameController.dispose();
    _linkNameController.dispose();
    _linkNicknameController.dispose();
    _linkCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitQuickStart() async {
    final name = _quickNameController.text.trim();
    if (name.isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.quickStart(
      name: name,
      nickname: _quickNicknameController.text.trim(),
    );

    if (!success && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  void _submitQuickLink() async {
    final name = _linkNameController.text.trim();
    final code = _linkCodeController.text.trim();

    if (name.isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return;
    }
    if (code.isEmpty) {
      _showError('Por favor ingresa el código de tu pareja');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.quickLink(
      name: name,
      pairingCode: code,
      nickname: _linkNicknameController.text.trim(),
    );

    if (!success && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  void _submitClassicLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresa un correo electrónico válido');
      return;
    }
    if (password.isEmpty) {
      _showError('Ingresa tu contraseña');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      email: email,
      password: password,
    );

    if (!success && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF0F3), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // Glowing Heart
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.softPink,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryRose.withOpacity(0.25),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppTheme.primaryRose,
                            size: 36,
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 1000.ms,
                            ),

                        const SizedBox(height: 8),

                        Text(
                          'My Heart',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.deepWine,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'Elige cómo deseas entrar a tu espacio',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),

                        const SizedBox(height: 16),

                        // Tab Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.softPink.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: AppTheme.primaryRose,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppTheme.deepWine,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              tabs: const [
                                Tab(text: '✨ Rápido'),
                                Tab(text: '🔗 Tengo Código'),
                                Tab(text: '🔑 Con Correo'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tab Bar View with fixed min height for clean typing
                        SizedBox(
                          height: 380,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: Quick Start (No email, no password!)
                              _buildQuickStartTab(auth),

                              // Tab 2: Quick Link (Partner's code)
                              _buildQuickLinkTab(auth),

                              // Tab 3: Classic Email Login
                              _buildClassicLoginTab(auth),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Demo Mode Button (Explore without partner)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: TextButton.icon(
                            onPressed: () {
                              final couple = Provider.of<CoupleProvider>(context, listen: false);
                              auth.enterDemoMode(name: 'Gabriel', nickname: 'Mi Amor');
                              couple.loadDemoData();
                            },
                            icon: const Icon(Icons.explore_rounded, color: AppTheme.primaryRose, size: 18),
                            label: const Text(
                              '🚀 Explorar todo en Modo Demo (Sin vinculación)',
                              style: TextStyle(
                                color: AppTheme.primaryRose,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStartTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrar sin contraseña 🚀',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
              ),
              const SizedBox(height: 6),
              const Text(
                'Solo ingresa tu nombre y te daremos un código para invitar a tu pareja.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quickNameController,
                decoration: const InputDecoration(
                  labelText: 'Tu Nombre',
                  hintText: 'Ej. Gabriel, Sofia',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _quickNicknameController,
                decoration: const InputDecoration(
                  labelText: 'Apodo cariñoso (opcional)',
                  hintText: 'Ej. Mi Amor, Bebé',
                  prefixIcon: Icon(Icons.favorite_border_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitQuickStart,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Empezar Ahora ✨',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinkTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vincularme con mi Pareja 💖',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa el código que te envió tu pareja (ej. HEART-4892) para conectarse de inmediato.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _linkCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Código de tu Pareja',
                  hintText: 'Ej. HEART-1234',
                  prefixIcon: Icon(Icons.qr_code_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _linkNameController,
                decoration: const InputDecoration(
                  labelText: 'Tu Nombre',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _linkNicknameController,
                decoration: const InputDecoration(
                  labelText: 'Apodo cariñoso (opcional)',
                  prefixIcon: Icon(Icons.favorite_border_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitQuickLink,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Conectarme con mi Amor 💕',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicLoginTab(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cuenta con Correo 🔑',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitClassicLogin,
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    '¿Crear cuenta con correo? Regístrate',
                    style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
