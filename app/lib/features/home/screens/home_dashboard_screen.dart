import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../widgets_studio/screens/widgets_studio_screen.dart';
import '../../pet/screens/pet_sanctuary_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../heartbeat/widgets/heart_animation_overlay.dart';
import '../../music/widgets/couple_music_player.dart';
import '../../places/screens/places_map_screen.dart';
import '../../games/screens/couple_games_hub_screen.dart';
import '../../calendar/screens/couple_calendar_screen.dart';
import '../../sticky_notes/widgets/sticky_notes_board.dart';
import '../../pairing/screens/pairing_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  // ─── Mood Picker ──────────────────────────────────────────────────────────

  void _showMoodPicker(BuildContext context) {
    final auth  = Provider.of<AuthProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    final moods = [
      {'status': 'Enamorado/a 🥰',         'icon': '🥰'},
      {'status': 'Pensando en ti 💭',       'icon': '💭'},
      {'status': 'Te extraño mucho 🥺',    'icon': '🥺'},
      {'status': 'Trabajando 💻',           'icon': '💻'},
      {'status': 'Con hambre 🍕',           'icon': '🍕'},
      {'status': 'Cansado/a pero feliz 😴', 'icon': '😴'},
      {'status': 'Listo/a para una cita 🍷','icon': '🍷'},
      {'status': 'Abrazable 🤗',            'icon': '🤗'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: AppTheme.blushPink, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('¿Cómo te sientes ahora? 💫',
                style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: moods.map((m) => ActionChip(
                avatar: Text(m['icon']!, style: const TextStyle(fontSize: 16)),
                label: Text(m['status']!),
                backgroundColor: theme.softAccentColor.withOpacity(0.4),
                labelStyle: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                shape: StadiumBorder(side: BorderSide(color: theme.softAccentColor, width: 1)),
                onPressed: () {
                  auth.updateMood(m['status']!, m['icon']!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Estado: ${m['status']}')),
                  );
                },
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Settings Modal ───────────────────────────────────────────────────────

  void _showSettingsModal(BuildContext context, AuthProvider auth, CoupleProvider couple, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppTheme.blushPink, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ajustes & Cuenta 💖',
                    style: TextStyle(color: theme.secondaryColor, fontWeight: FontWeight.w700, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            _settingsUserTile(auth, theme, ctx, context),
            const Divider(height: 24),
            _settingsCoupleTile(auth, couple, theme, ctx, context),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade800,
                    side: BorderSide(color: Colors.orange.shade300),
                    shape: StadiumBorder(),
                  ),
                  onPressed: () { Navigator.pop(ctx); auth.logout(); },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Cerrar Sesión'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () { Navigator.pop(ctx); _showDeleteAccountConfirmation(context, auth); },
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
                  label: const Text('Eliminar Cuenta', style: TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _settingsUserTile(AuthProvider auth, ThemeProvider theme, BuildContext sheetCtx, BuildContext navCtx) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(gradient: theme.mainGradient, shape: BoxShape.circle),
        child: Center(
          child: Text(
            (auth.currentUser?['name'] ?? 'U')[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      title: Text(auth.currentUser?['name'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(auth.currentUser?['nickname'] ?? 'Sin apodo',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      trailing: TextButton(
        onPressed: () {
          Navigator.pop(sheetCtx);
          Navigator.of(navCtx).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        child: const Text('Editar perfil'),
      ),
    );
  }

  Widget _settingsCoupleTile(AuthProvider auth, CoupleProvider couple, ThemeProvider theme, BuildContext sheetCtx, BuildContext navCtx) {
    if (!auth.isPaired) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: theme.softAccentColor, shape: BoxShape.circle),
          child: Center(child: Icon(Icons.link_rounded, color: theme.primaryColor, size: 24)),
        ),
        title: const Text('Pareja: No vinculada', style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text('Toca para vincular a tu amor', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            Navigator.pop(sheetCtx);
            Navigator.of(navCtx).push(MaterialPageRoute(builder: (_) => const PairingScreen()));
          },
          child: const Text('Vincular', style: TextStyle(fontSize: 12, color: Colors.white)),
        ),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: theme.softAccentColor, shape: BoxShape.circle),
        child: Center(child: Text(
          (auth.partnerUser?['name'] ?? 'P')[0].toUpperCase(),
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        )),
      ),
      title: Text(auth.partnerUser?['name'] ?? 'Mi Amor', style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('Mascota: ${couple.petName} · Nivel ${couple.petLevel}',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          SizedBox(width: 8),
          Text('¿Eliminar Cuenta? 🗑️'),
        ]),
        content: const Text(
            'Esta acción eliminará permanentemente tu usuario, recuerdos, cartas y todos los datos sin dejar registros huérfanos.\n\n¿Estás completamente seguro/a?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await auth.deleteAccount();
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada con éxito.')));
              }
            },
            child: const Text('Sí, Eliminar Todo', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAnniversaryDate(BuildContext context, CoupleProvider couple) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '¿CUÁNDO COMENZÓ SU HISTORIA?',
    );
    if (picked != null && couple.coupleData != null && context.mounted) {
      couple.coupleData!['anniversary_date'] = picked.toIso8601String().split('T').first;
      couple.coupleData!['relationship_time_start'] = picked.toIso8601String();
      couple.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aniversario: ${DateFormat('dd MMM yyyy').format(picked)} 💖')),
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);
    final theme  = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.softBackground,
          extendBodyBehindAppBar: false,
          appBar: _buildBlurAppBar(context, auth, couple, theme),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 0. Pairing Callout Banner (if not paired yet)
                      if (!auth.isPaired)
                        _buildPairingCalloutBanner(context, theme)
                            .animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),

                      // 1. Dual Avatars Hero
                      _buildDualAvatarsSection(context, auth.currentUser, auth.partnerUser, theme, auth.isPaired)
                          .animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 16),

                      // 2. Love Counter (Hero card)
                      _buildLoveCounterCard(context, couple, theme)
                          .animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                      const SizedBox(height: 16),

                      // 3. Quick Feature Grid
                      _buildFeatureGrid(context, theme)
                          .animate(delay: 160.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // 4. Music Player
                      const CoupleMusicPlayer()
                          .animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // 5. Heartbeat + Pet
                      _buildHeartbeatAndPetSection(context, auth, couple, theme)
                          .animate(delay: 240.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // 6. Sticky Notes
                      const StickyNotesBoard()
                          .animate(delay: 280.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // 7. Daily Spark Banner
                      _buildDailySparkBanner(context, couple, theme)
                          .animate(delay: 320.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // 8. Widgets Studio
                      _buildWidgetsStudioBanner(context, theme)
                          .animate(delay: 360.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (couple.showHeartbeatAnimation)
          HeartAnimationOverlay(
            senderName: couple.lastHeartbeatSender ?? 'Tu pareja',
            onDismiss: () {},
          ),
      ],
    );
  }

  // ─── Header AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildBlurAppBar(BuildContext context, AuthProvider auth, CoupleProvider couple, ThemeProvider theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => AppTheme.loveGradient.createShader(b),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (b) => AppTheme.loveGradient.createShader(b),
              child: const Text(
                'My Heart',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.palette_outlined, color: theme.primaryColor),
            tooltip: 'Personalizar',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: theme.secondaryColor),
            tooltip: 'Ajustes',
            onPressed: () => _showSettingsModal(context, auth, couple, theme),
          ),
        ],
      ),
    );
  }


  Widget _buildPairingCalloutBanner(BuildContext context, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PairingScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.12),
              theme.primaryColor.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: theme.primaryColor.withOpacity(0.25), width: 1.2),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: theme.mainGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.link_rounded, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Vincula a tu Pareja! 💖',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Comparte tu código o ingresa el de tu amor para conectar su espacio.',
                    style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: theme.mainGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Vincular',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dual Avatars Hero ────────────────────────────────────────────────────

  Widget _buildDualAvatarsSection(
    BuildContext context,
    Map<String, dynamic>? user,
    Map<String, dynamic>? partner,
    ThemeProvider theme,
    bool isPaired,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: theme.softAccentColor.withOpacity(0.8), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => _showMoodPicker(context),
            child: _buildAvatar(
              name: user?['nickname'] ?? user?['name'] ?? 'Tú',
              mood: user?['mood_status'] ?? 'Enamorado/a 🥰',
              icon: user?['mood_icon'] ?? '🥰',
              isMe: true,
              theme: theme,
            ),
          ),
          _buildHeartBridge(theme),
          if (isPaired && partner != null && partner['id'] != null)
            _buildAvatar(
              name: partner['nickname'] ?? partner['name'] ?? 'Mi Amor',
              mood: partner['mood_status'] ?? 'Pensando en ti 💭',
              icon: partner['mood_icon'] ?? '💭',
              isMe: false,
              isOnline: partner['is_online'] ?? true,
              theme: theme,
            )
          else
            _buildUnpairedPartnerAvatar(context, theme),
        ],
      ),
    );
  }

  Widget _buildUnpairedPartnerAvatar(BuildContext context, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PairingScreen()),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.softAccentColor.withOpacity(0.4),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 1500.ms),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: theme.primaryColor,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                    border: Border.all(color: theme.softAccentColor, width: 1.5),
                  ),
                  child: const Text('💖', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu Pareja',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            'Toca para vincular 💕',
            style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartBridge(ThemeProvider theme) {
    return Column(
      children: [
        Container(
          width: 1,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, theme.primaryColor.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: theme.mainGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(1, 1), end: const Offset(1.18, 1.18), duration: 900.ms, curve: Curves.easeInOut),
        Container(
          width: 1,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Juntos ∞',
          style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildAvatar({
    required String name,
    required String mood,
    required String icon,
    required bool isMe,
    bool isOnline = false,
    required ThemeProvider theme,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer aura ring
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isMe
                    ? LinearGradient(colors: [
                        theme.primaryColor.withOpacity(0.2),
                        theme.primaryColor.withOpacity(0.05),
                      ])
                    : LinearGradient(colors: [
                        theme.secondaryColor.withOpacity(0.15),
                        theme.secondaryColor.withOpacity(0.04),
                      ]),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 2000.ms),

            // Avatar circle
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isMe ? theme.mainGradient : LinearGradient(
                      colors: [theme.secondaryColor, theme.secondaryColor.withOpacity(0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isMe ? theme.primaryColor : theme.secondaryColor).withOpacity(0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '♥',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            // Mood badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
                  border: Border.all(color: theme.softAccentColor, width: 1.5),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 13)),
              ),
            ),

            // Online dot
            if (!isMe && isOnline)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D97E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1500.ms),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
        ),
        const SizedBox(height: 2),
        Container(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            mood,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ),
        if (isMe)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Toca para cambiar',
              style: TextStyle(fontSize: 10, color: theme.primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  // ─── Love Counter Card ────────────────────────────────────────────────────

  Widget _buildLoveCounterCard(BuildContext context, CoupleProvider couple, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => _pickAnniversaryDate(context, couple),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: theme.mainGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.heroShadow,
        ),
        child: Stack(
          children: [
            // Shimmer sweep overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 3000.ms, color: Colors.white.withOpacity(0.12)),
            ),

            Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'NUESTRA HISTORIA DE AMOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Big days number
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${couple.daysTogether}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Playfair Display',
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 8),
                      child: Text(
                        'días',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Time badges row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _timeBadge(couple.hoursTogether.toString().padLeft(2, '0'), 'horas'),
                      _timeSep(),
                      _timeBadge(couple.minutesTogether.toString().padLeft(2, '0'), 'min'),
                      _timeSep(),
                      _timeBadge(couple.secondsTogether.toString().padLeft(2, '0'), 'seg'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.touch_app_rounded, color: Colors.white38, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Toca para cambiar la fecha de aniversario',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBadge(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _timeSep() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(':', style: TextStyle(color: Colors.white60, fontSize: 22, fontWeight: FontWeight.w300)),
    );
  }

  // ─── Feature Grid ─────────────────────────────────────────────────────────

  Widget _buildFeatureGrid(BuildContext context, ThemeProvider theme) {
    final features = [
      _FeatureItem('🗺️', 'Lugares',    () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlacesMapScreen()))),
      _FeatureItem('🎲', 'Juegos',     () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoupleGamesHubScreen()))),
      _FeatureItem('📅', 'Calendario', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CoupleCalendarScreen()))),
    ];

    return Row(
      children: features.asMap().entries.map((e) {
        final i    = e.key;
        final item = e.value;
        return [
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _FeatureCard(item: item, theme: theme),
          ),
        ];
      }).expand((x) => x).toList(),
    );
  }

  // ─── Heartbeat + Pet ──────────────────────────────────────────────────────

  Widget _buildHeartbeatAndPetSection(
    BuildContext context,
    AuthProvider auth,
    CoupleProvider couple,
    ThemeProvider theme,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              final user = auth.currentUser;
              if (user != null) {
                couple.sendHeartbeat(
                  userId: user['id'],
                  userName: user['nickname'] ?? user['name'] ?? 'Tú',
                );
              }
            },
            child: Container(
              height: 148,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: theme.softAccentColor.withOpacity(0.8), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: theme.mainGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.14, 1.14), duration: 800.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 10),
                  Text('Enviar Latido',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.secondaryColor)),
                  const SizedBox(height: 2),
                  const Text('Vibra su celular 💕', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetSanctuaryScreen())),
            child: Container(
              height: 148,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.cardShadow,
                border: Border.all(color: theme.softAccentColor.withOpacity(0.8), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    couple.petLevel >= 5 ? '🐉' : couple.petLevel >= 3 ? '🐺' : '🐾',
                    style: const TextStyle(fontSize: 34),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: 0, end: -4, duration: 1200.ms, curve: Curves.easeInOut),
                  const SizedBox(height: 6),
                  Text(
                    couple.petName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
                  ),
                  Text(
                    'Nivel ${couple.petLevel}',
                    style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    child: LinearProgressIndicator(
                      value: (couple.petXp % 100) / 100.0,
                      backgroundColor: theme.softAccentColor,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para cuidar 🍖',
                    style: TextStyle(fontSize: 9, color: theme.primaryColor, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Daily Spark Banner ───────────────────────────────────────────────────

  Widget _buildDailySparkBanner(BuildContext context, CoupleProvider couple, ThemeProvider theme) {
    final isAnswered = couple.todayQuestion?['user_answered'] ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.08),
            theme.primaryColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: theme.primaryColor.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: theme.mainGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 10)],
            ),
            child: const Center(child: Text('💬', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnswered ? '¡Ya respondiste hoy! ✅' : 'Pregunta del Día 💫',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: theme.secondaryColor),
                ),
                const SizedBox(height: 2),
                Text(
                  isAnswered ? 'Revisa lo que respondió tu pareja.' : 'Descubre qué piensa tu pareja hoy.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, size: 16, color: theme.primaryColor),
          ),
        ],
      ),
    );
  }

  // ─── Widgets Studio Banner ────────────────────────────────────────────────

  Widget _buildWidgetsStudioBanner(BuildContext context, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WidgetsStudioScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: theme.softAccentColor.withOpacity(0.8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor.withOpacity(0.15), theme.primaryColor.withOpacity(0.05)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(Icons.widgets_rounded, color: theme.primaryColor, size: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widgets de Pantalla de Inicio 📱',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: theme.secondaryColor),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Añade el contador de amor directo en tu celular.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureItem {
  const _FeatureItem(this.emoji, this.label, this.onTap);
  final String emoji;
  final String label;
  final VoidCallback onTap;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.item, required this.theme});
  final _FeatureItem item;
  final ThemeProvider theme;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.item.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.cardShadow,
            border: Border.all(color: widget.theme.softAccentColor.withOpacity(0.8), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.theme.primaryColor.withOpacity(0.12),
                      widget.theme.primaryColor.withOpacity(0.04),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(widget.item.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.theme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
