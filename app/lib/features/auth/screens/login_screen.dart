import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegisterMode = false;

  // Controllers for Login
  final _loginEmailController    = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Controllers for Register
  final _regNameController     = TextEditingController();
  final _regNicknameController = TextEditingController();
  final _regEmailController    = TextEditingController();
  final _regPasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regNicknameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresa un correo electrónico válido');
      return;
    }
    if (password.isEmpty) {
      _showError('Ingresa tu contraseña');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.login(email: email, password: password);
    if (!ok && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _submitRegister() async {
    final name = _regNameController.text.trim();
    final nickname = _regNicknameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty) {
      _showError('Por favor ingresa tu nombre');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Ingresa un correo electrónico válido');
      return;
    }
    if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.register(
      name: name,
      nickname: nickname.isNotEmpty ? nickname : null,
      email: email,
      password: password,
    );
    if (!ok && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Hero Logo ──────────────────────────────────────────
                _buildHeroLogo(),

                const SizedBox(height: 8),

                Text(
                  'Tu espacio íntimo y privado para dos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.deepWine.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Switcher Tab (Iniciar Sesión / Crear Cuenta) ────────
                _buildModeSwitcher(),

                const SizedBox(height: 20),

                // ── Form Container ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.cardShadow,
                    border: Border.all(
                      color: AppTheme.primaryRose.withOpacity(0.12),
                      width: 1.2,
                    ),
                  ),
                  child: _isRegisterMode
                      ? _buildRegisterForm(auth)
                      : _buildLoginForm(auth),
                ),

                const SizedBox(height: 20),

                // ── Bottom Toggle Link ─────────────────────────────────
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                    });
                  },
                  child: Text(
                    _isRegisterMode
                        ? '¿Ya tienes una cuenta? Inicia sesión aquí'
                        : '¿Nuevo en My Heart? Crea tu cuenta aquí',
                    style: const TextStyle(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLogo() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.loveGradient,
            boxShadow: AppTheme.heroShadow,
          ),
          child: const Center(
            child: Icon(Icons.favorite_rounded, color: Colors.white, size: 38),
          ),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.loveGradient.createShader(bounds),
          child: const Text(
            'My Heart',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Playfair Display',
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.primaryRose.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegisterMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: !_isRegisterMode ? AppTheme.loveGradient : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: !_isRegisterMode ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isRegisterMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _isRegisterMode ? AppTheme.loveGradient : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    color: _isRegisterMode ? Colors.white : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bienvenido de nuevo 💖',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepWine,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ingresa tu correo y contraseña para entrar.',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'tu@correo.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRose),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(
          label: 'Ingresar a My Heart ✨',
          isLoading: auth.isLoading,
          onPressed: _submitLogin,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crea tu Cuenta 💌',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.deepWine,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Regístrate para vincularte con tu pareja.',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _regNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Tu Nombre',
            hintText: 'Ej. Gabriel, Sofía',
            prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regNicknameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Apodo cariñoso (opcional)',
            hintText: 'Ej. Mi Amor, Bebé',
            prefixIcon: Icon(Icons.favorite_border_rounded, color: AppTheme.primaryRose),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            hintText: 'tu@correo.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryRose),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Contraseña (mínimo 6 caracteres)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(
          label: 'Crear Cuenta y Continuar 💕',
          isLoading: auth.isLoading,
          onPressed: _submitRegister,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.loveGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        boxShadow: AppTheme.heroShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
