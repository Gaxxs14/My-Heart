import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
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

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  void _showMoodPicker(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final theme = Provider.of<ThemeProvider>(context, listen: false);

    final moods = [
      {'status': 'Enamorado/a 🥰', 'icon': '🥰'},
      {'status': 'Pensando en ti 💭', 'icon': '💭'},
      {'status': 'Te extraño mucho 🥺', 'icon': '🥺'},
      {'status': 'Trabajando 💻', 'icon': '💻'},
      {'status': 'Con hambre 🍕', 'icon': '🍕'},
      {'status': 'Cansado/a pero feliz 😴', 'icon': '😴'},
      {'status': 'Listo/a para una cita 🍷', 'icon': '🍷'},
      {'status': 'Abrazable 🤗', 'icon': '🤗'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '¿Cómo te sientes ahora?',
                    style: TextStyle(
                      color: theme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: moods.map((m) {
                  return ActionChip(
                    avatar: Text(m['icon']!, style: const TextStyle(fontSize: 18)),
                    label: Text(m['status']!),
                    backgroundColor: theme.softAccentColor.withOpacity(0.5),
                    labelStyle: TextStyle(
                      color: theme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.softAccentColor),
                    ),
                    onPressed: () {
                      auth.updateMood(m['status']!, m['icon']!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Estado actualizado a: ${m['status']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsModal(BuildContext context, AuthProvider auth, CoupleProvider couple, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajustes & Cuenta 💖',
                    style: TextStyle(
                      color: theme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.softAccentColor,
                  child: Icon(Icons.person_rounded, color: theme.primaryColor),
                ),
                title: Text(auth.currentUser?['name'] ?? 'Usuario'),
                subtitle: Text('Apodo: ${auth.currentUser?['nickname'] ?? 'Sin apodo'} • ${auth.isDemoMode ? "Modo Demo" : "Conectado a la Nube"}'),
                trailing: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Editar'),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.softAccentColor,
                  child: Icon(Icons.favorite_rounded, color: theme.primaryColor),
                ),
                title: Text('Pareja: ${auth.partnerUser?['name'] ?? "Mi Amor"}'),
                subtitle: Text('Mascota: ${couple.petName} (Nivel ${couple.petLevel})'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    auth.logout();
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text('Cerrar Sesión / Salir'),
                ),
              ),
            ],
          ),
        );
      },
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

    if (picked != null && couple.coupleData != null) {
      couple.coupleData!['anniversary_date'] = picked.toIso8601String().split('T').first;
      couple.coupleData!['relationship_time_start'] = picked.toIso8601String();
      couple.notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Fecha de aniversario actualizada al ${DateFormat('dd MMM yyyy').format(picked)}! 💖')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);

    final currentUser = auth.currentUser;
    final partnerUser = auth.partnerUser;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Icon(Icons.favorite, color: theme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'My Heart',
                  style: TextStyle(
                    color: theme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.palette_outlined, color: theme.secondaryColor),
                tooltip: 'Personalizar Colores',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: theme.secondaryColor),
                tooltip: 'Ajustes',
                onPressed: () => _showSettingsModal(context, auth, couple, theme),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (auth.isDemoMode)
                  GestureDetector(
                    onTap: () => _showSettingsModal(context, auth, couple, theme),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Estás en Modo Demo. Toca aquí para ver ajustes o vincularte con tu pareja real.',
                              style: TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.orange),
                        ],
                      ),
                    ),
                  ),

                // 1. Dual Avatars with mood
                _buildDualAvatarsSection(context, currentUser, partnerUser, theme),

                const SizedBox(height: 16),

                // 2. Our Love Song (Music Player)
                const CoupleMusicPlayer(),

                const SizedBox(height: 16),

                // 3. Love Counter Card (Days, Hours, Minutes, Seconds)
                _buildLoveCounterCard(context, couple, theme),

                const SizedBox(height: 16),

                // 4. Quick Features Bar: Lugares 🗺️, Minijuegos 🎲, Calendario 📅
                _buildQuickFeaturesBar(context, theme),

                const SizedBox(height: 16),

                // 5. Heartbeat Button & Pet Card
                _buildHeartbeatAndPetSection(context, auth, couple, theme),

                const SizedBox(height: 16),

                // 6. Sticky Notes Board (Post-its)
                const StickyNotesBoard(),

                const SizedBox(height: 16),

                // 7. Daily Spark Banner
                _buildDailySparkBanner(context, couple, theme),

                const SizedBox(height: 16),

                // 8. Widgets Studio Shortcut
                _buildWidgetsStudioBanner(context, theme),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Fullscreen Heartbeat Celebration Animation
        if (couple.showHeartbeatAnimation)
          HeartAnimationOverlay(
            senderName: couple.lastHeartbeatSender ?? 'Tu pareja',
            onDismiss: () {},
          ),
      ],
    );
  }

  Widget _buildDualAvatarsSection(
    BuildContext context,
    Map<String, dynamic>? user,
    Map<String, dynamic>? partner,
    ThemeProvider theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.softAccentColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Current User Avatar
          GestureDetector(
            onTap: () => _showMoodPicker(context),
            child: _buildAvatarCard(
              name: user?['nickname'] ?? user?['name'] ?? 'Tú',
              mood: user?['mood_status'] ?? 'Enamorado/a 🥰',
              icon: user?['mood_icon'] ?? '🥰',
              isMe: true,
              theme: theme,
            ),
          ),

          // Glowing heart bridge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.softAccentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: theme.primaryColor,
                  size: 22,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 1000.ms,
                  ),
              const SizedBox(height: 4),
              const Text(
                'Juntos',
                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Partner Avatar
          _buildAvatarCard(
            name: partner?['nickname'] ?? partner?['name'] ?? 'Mi Amor',
            mood: partner?['mood_status'] ?? 'Pensando en ti 💭',
            icon: partner?['mood_icon'] ?? '💭',
            isMe: false,
            isOnline: partner?['is_online'] ?? true,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard({
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isMe ? theme.mainGradient : null,
                color: isMe ? null : theme.secondaryColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '♥',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Mood badge
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.softAccentColor, width: 1.5),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 14)),
              ),
            ),
            if (!isMe && isOnline)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          constraints: const BoxConstraints(maxWidth: 110),
          child: Text(
            mood,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ),
        if (isMe)
          Text(
            '(Toca para cambiar)',
            style: TextStyle(fontSize: 10, color: theme.primaryColor),
          ),
      ],
    );
  }

  Widget _buildLoveCounterCard(BuildContext context, CoupleProvider couple, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => _pickAnniversaryDate(context, couple),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: theme.mainGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
                SizedBox(width: 6),
                Text(
                  'NUESTRA HISTORIA DE AMOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 18),
              ],
            ),
            const SizedBox(height: 14),

            // Giant Days Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${couple.daysTogether}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Días',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Clock ticker: Hours, Minutes, Seconds
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeBadge(couple.hoursTogether.toString().padLeft(2, '0'), 'Horas'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _buildTimeBadge(couple.minutesTogether.toString().padLeft(2, '0'), 'Minutos'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _buildTimeBadge(couple.secondsTogether.toString().padLeft(2, '0'), 'Segundos'),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '(Toca para cambiar fecha de aniversario)',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFeaturesBar(BuildContext context, ThemeProvider theme) {
    return Row(
      children: [
        _buildFeatureButton(
          context,
          emoji: '🗺️',
          label: 'Lugares',
          theme: theme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlacesMapScreen()),
            );
          },
        ),
        const SizedBox(width: 12),
        _buildFeatureButton(
          context,
          emoji: '🎲',
          label: 'Minijuegos',
          theme: theme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CoupleGamesHubScreen()),
            );
          },
        ),
        const SizedBox(width: 12),
        _buildFeatureButton(
          context,
          emoji: '📅',
          label: 'Calendario',
          theme: theme,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CoupleCalendarScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required String emoji,
    required String label,
    required ThemeProvider theme,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.softAccentColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartbeatAndPetSection(
    BuildContext context,
    AuthProvider auth,
    CoupleProvider couple,
    ThemeProvider theme,
  ) {
    return Row(
      children: [
        // Heartbeat button
        Expanded(
          flex: 1,
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
              height: 140,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.softAccentColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.softAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.15, 1.15),
                        duration: 800.ms,
                      ),
                  const SizedBox(height: 8),
                  Text(
                    'Enviar Latido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.secondaryColor,
                    ),
                  ),
                  const Text(
                    'Vibra su cel 💕',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Virtual Pet Card (Opens Pet Sanctuary)
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PetSanctuaryScreen()),
              );
            },
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.softAccentColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 4),
                  Text(
                    couple.petName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  Text(
                    'Nivel ${couple.petLevel}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (couple.petXp % 100) / 100.0,
                      backgroundColor: theme.softAccentColor,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca para cuidar 🍖',
                    style: TextStyle(fontSize: 9, color: theme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailySparkBanner(BuildContext context, CoupleProvider couple, ThemeProvider theme) {
    final todayQ = couple.todayQuestion;
    final isAnswered = todayQ?['user_answered'] ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.softAccentColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text('💬', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pregunta del Día',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAnswered ? '¡Ya respondiste hoy! Revisa lo que dijo tu pareja.' : 'Descubre qué piensa tu pareja hoy.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildWidgetsStudioBanner(BuildContext context, ThemeProvider theme) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WidgetsStudioScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.softAccentColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.softAccentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.widgets_rounded, color: theme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Widgets de Pantalla de Inicio 📱',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ver vistas previas y cómo agregarlos a tu celular.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}
