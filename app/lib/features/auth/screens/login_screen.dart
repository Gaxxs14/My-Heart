import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _bgController;

  // Controllers
  final _quickNameController       = TextEditingController();
  final _quickNicknameController   = TextEditingController();
  final _linkNameController        = TextEditingController();
  final _linkNicknameController    = TextEditingController();
  final _linkCodeController        = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bgController  = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bgController.dispose();
    _quickNameController.dispose();
    _quickNicknameController.dispose();
    _linkNameController.dispose();
    _linkNicknameController.dispose();
    _linkCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _submitQuickStart() async {
    final name = _quickNameController.text.trim();
    if (name.isEmpty) { _showError('Por favor ingresa tu nombre'); return; }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok   = await auth.quickStart(name: name, nickname: _quickNicknameController.text.trim());
    if (!ok && mounted && auth.errorMessage != null) _showError(auth.errorMessage!);
  }

  Future<void> _submitQuickLink() async {
    final name = _linkNameController.text.trim();
    final code = _linkCodeController.text.trim();
    if (name.isEmpty) { _showError('Por favor ingresa tu nombre'); return; }
    if (code.isEmpty) { _showError('Por favor ingresa el código de tu pareja'); return; }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok   = await auth.quickLink(name: name, pairingCode: code, nickname: _linkNicknameController.text.trim());
    if (!ok && mounted && auth.errorMessage != null) _showError(auth.errorMessage!);
  }

  Future<void> _submitClassicLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) { _showError('Ingresa un correo válido'); return; }
    if (password.isEmpty) { _showError('Ingresa tu contraseña'); return; }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok   = await auth.login(email: email, password: password);
    if (!ok && mounted && auth.errorMessage != null) _showError(auth.errorMessage!);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Animated Bokeh Background ──────────────────────────────────
          _BokehBackground(controller: _bgController, size: size),

          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 28),

                          // ── Hero Logo ───────────────────────────────
                          _buildHeroLogo()
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

                          const SizedBox(height: 10),

                          // ── Tag line ─────────────────────────────────
                          Text(
                            'Tu espacio romántico privado',
                            style: TextStyle(
                              color: AppTheme.deepWine.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          )
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 500.ms),

                          const SizedBox(height: 28),

                          // ── Tab Selector ─────────────────────────────
                          _buildTabSelector()
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: 12),

                          // ── Tab Content ──────────────────────────────
                          SizedBox(
                            height: 380,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildQuickStartTab(auth),
                                _buildQuickLinkTab(auth),
                                _buildClassicLoginTab(auth),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Logo ────────────────────────────────────────────────────────────

  Widget _buildHeroLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.loveGradient,
            boxShadow: AppTheme.heroShadow,
          ),
          child: const Center(
            child: Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1800.ms, curve: Curves.easeInOut),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.loveGradient.createShader(bounds),
          child: const Text(
            'My Heart',
            style: TextStyle(
              fontSize: 30,
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

  // ─── Tab Selector ─────────────────────────────────────────────────────────

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: AppTheme.primaryRose.withOpacity(0.18),
                width: 1.2,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.loveGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: '✨ Rápido'),
                Tab(text: '🔗 Código'),
                Tab(text: '🔑 Correo'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Form Card wrapper ────────────────────────────────────────────────────

  Widget _formCard(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // ─── Tab 1: Quick Start ───────────────────────────────────────────────────

  Widget _buildQuickStartTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: _formCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Entrar sin contraseña', '🚀',
                'Ingresa tu nombre y te daremos un código para invitar a tu pareja.'),
            const SizedBox(height: 18),
            _fancyField(_quickNameController, 'Tu Nombre', 'Gabriel, Sofía', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _fancyField(_quickNicknameController, 'Apodo cariñoso (opcional)', 'Mi Amor, Bebé', Icons.favorite_border_rounded),
            const SizedBox(height: 22),
            _gradientButton(
              label: 'Empezar Ahora ✨',
              isLoading: auth.isLoading,
              onPressed: _submitQuickStart,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 2: Quick Link ────────────────────────────────────────────────────

  Widget _buildQuickLinkTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: _formCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Vincularme con mi Pareja', '💖',
                'Ingresa el código que te envió tu pareja (ej. HEART-4892).'),
            const SizedBox(height: 18),
            _fancyField(_linkCodeController, 'Código de tu Pareja', 'HEART-1234', Icons.qr_code_rounded,
                caps: TextCapitalization.characters),
            const SizedBox(height: 12),
            _fancyField(_linkNameController, 'Tu Nombre', 'Gabriel, Sofía', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _fancyField(_linkNicknameController, 'Apodo cariñoso (opcional)', 'Mi Amor', Icons.favorite_border_rounded),
            const SizedBox(height: 22),
            _gradientButton(
              label: 'Conectarme con mi Amor 💕',
              isLoading: auth.isLoading,
              onPressed: _submitQuickLink,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 3: Classic Login ─────────────────────────────────────────────────

  Widget _buildClassicLoginTab(AuthProvider auth) {
    return SingleChildScrollView(
      child: _formCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabHeader('Cuenta con Correo', '🔑', ''),
            const SizedBox(height: 18),
            _fancyField(_emailController, 'Correo electrónico', 'tu@email.com', Icons.email_outlined,
                type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _fancyField(_passwordController, 'Contraseña', '••••••••', Icons.lock_outline_rounded,
                obscure: true),
            const SizedBox(height: 22),
            _gradientButton(
              label: 'Iniciar Sesión',
              isLoading: auth.isLoading,
              onPressed: _submitClassicLogin,
            ),
            const SizedBox(height: 14),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(
                  '¿No tienes cuenta? Regístrate →',
                  style: TextStyle(
                    color: AppTheme.primaryRose,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _tabHeader(String title, String emoji, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.deepWine,
                ),
              ),
            ),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4)),
        ],
      ],
    );
  }

  Widget _fancyField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
    TextCapitalization caps = TextCapitalization.words,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      textCapitalization: caps,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryRose, size: 20),
      ),
    );
  }

  Widget _gradientButton({
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
          splashColor: Colors.white24,
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

// ─── Bokeh Background ─────────────────────────────────────────────────────────

class _BokehBackground extends StatelessWidget {
  const _BokehBackground({required this.controller, required this.size});
  final AnimationController controller;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Stack(
          children: [
            // Base gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFF0F5),
                    const Color(0xFFFFF8FA),
                    const Color(0xFFFFF0F5).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Blobs
            _blob(size, t, 0.15, 0.08, 160, const Color(0xFFFF9AB2), 0.18),
            _blob(size, t, 0.80, 0.20, 120, const Color(0xFFFFB347), 0.12),
            _blob(size, t, 0.05, 0.65, 100, const Color(0xFFB5A8FF), 0.10),
            _blob(size, t, 0.85, 0.75, 140, const Color(0xFFFF9AB2), 0.14),
            _blob(size, t, 0.45, 0.40, 80,  const Color(0xFFFF4D79), 0.08),
          ],
        );
      },
    );
  }

  Widget _blob(Size size, double t, double xBase, double yBase, double radius, Color color, double opacity) {
    final dx = math.sin(t * math.pi * 2 + xBase * 10) * 30;
    final dy = math.cos(t * math.pi * 2 + yBase * 10) * 20;
    return Positioned(
      left: size.width  * xBase + dx - radius,
      top:  size.height * yBase + dy - radius,
      child: Container(
        width:  radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
