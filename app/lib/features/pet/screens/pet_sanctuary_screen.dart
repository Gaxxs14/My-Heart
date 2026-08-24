import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

class PetSanctuaryScreen extends StatefulWidget {
  const PetSanctuaryScreen({super.key});

  @override
  State<PetSanctuaryScreen> createState() => _PetSanctuaryScreenState();
}

class _PetSanctuaryScreenState extends State<PetSanctuaryScreen> {
  String _selectedActionMessage = '';
  bool _showActionAnimation = false;

  void _interactWithPet(String actionName, int xpBonus, String emoji) {
    final couple = Provider.of<CoupleProvider>(context, listen: false);

    HapticFeedback.mediumImpact();
    couple.addPetXp(xpBonus);

    final msg = '¡$actionName! +$xpBonus XP $emoji';

    setState(() {
      _selectedActionMessage = msg;
      _showActionAnimation = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryRose,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showActionAnimation = false);
      }
    });
  }

  void _showChangePetDialog(CoupleProvider couple) {
    final petOptions = [
      {'type': 'puppy',  'name': 'Cachorrito',       'emoji': '🐶'},
      {'type': 'kitten', 'name': 'Gatito',           'emoji': '🐱'},
      {'type': 'bunny',  'name': 'Conejito',         'emoji': '🐰'},
      {'type': 'plant',  'name': 'Planta del Amor',  'emoji': '🪴'},
      {'type': 'bear',   'name': 'Osito Tierno',     'emoji': '🧸'},
      {'type': 'fox',    'name': 'Zorrito',          'emoji': '🦊'},
      {'type': 'panda',  'name': 'Pandita',          'emoji': '🐼'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.blushPink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Elige su Mascota Virtual 🐾',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.deepWine),
              ),
              const SizedBox(height: 6),
              const Text(
                'Toca una mascota para adoptarla juntos 💕',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: petOptions.map((p) {
                  final isSelected = couple.petType == p['type'];
                  return InkWell(
                    onTap: () {
                      couple.updatePet(type: p['type']!, name: p['name']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Adoptaron a ${p['name']} ${p['emoji']}! 💖'),
                          backgroundColor: AppTheme.primaryRose,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 96,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.softPink : const Color(0xFFFAF7F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryRose : const Color(0xFFF0E5EB),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(p['emoji']!, style: const TextStyle(fontSize: 34)),
                          const SizedBox(height: 6),
                          Text(
                            p['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPetEmoji(String? type, int level) {
    if (type == 'kitten') return level >= 5 ? '🐱👑' : '🐱';
    if (type == 'bunny')  return level >= 5 ? '🐰👑' : '🐰';
    if (type == 'plant')  return level >= 5 ? '🌸🪴' : '🪴';
    if (type == 'bear')   return level >= 5 ? '🧸👑' : '🧸';
    if (type == 'fox')    return level >= 5 ? '🦊👑' : '🦊';
    if (type == 'panda')  return level >= 5 ? '🐼👑' : '🐼';
    return level >= 5 ? '🐶👑' : '🐶';
  }

  @override
  Widget build(BuildContext context) {
    final couple = Provider.of<CoupleProvider>(context);
    final theme  = Provider.of<ThemeProvider>(context);

    final petType  = couple.petType;
    final petName  = couple.petName;
    final petLevel = couple.petLevel;
    final petXp    = couple.petXp;
    final xpInCurrentLevel = petXp % 100;

    return Scaffold(
      backgroundColor: AppTheme.softBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.deepWine),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Santuario de Amor 🐾',
          style: TextStyle(
            color: AppTheme.deepWine,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pets_rounded, color: AppTheme.primaryRose),
            tooltip: 'Cambiar Mascota',
            onPressed: () => _showChangePetDialog(couple),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Pet Title & Level Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  petName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Nivel $petLevel',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // XP Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Experiencia de Amor:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('$xpInCurrentLevel / 100 XP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: xpInCurrentLevel / 100.0,
                      backgroundColor: theme.softAccentColor,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Giant Pet Mascot with Animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Aura glow
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.softAccentColor.withOpacity(0.6),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 1500.ms,
                    ),

                // Mascot
                GestureDetector(
                  onTap: () => _interactWithPet('Acariciaste a $petName', 5, '💖'),
                  child: Text(
                    _getPetEmoji(petType, petLevel),
                    style: const TextStyle(fontSize: 100),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                        begin: 0,
                        end: -15,
                        duration: 1200.ms,
                        curve: Curves.easeInOut,
                      ),
                ),

                // Floating action text
                if (_showActionAnimation)
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: Text(
                        _selectedActionMessage,
                        style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ).animate().fadeIn().moveY(begin: 10, end: -20),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              '¡Toca a tu mascota para darle cariño!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const Spacer(),

            // 4 Care Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCareButton(
                    emoji: '🍖',
                    label: 'Alimentar',
                    xp: '+10 XP',
                    onTap: () => _interactWithPet('Alimentaste a $petName', 10, '🍖'),
                  ),
                  _buildCareButton(
                    emoji: '💖',
                    label: 'Acariciar',
                    xp: '+5 XP',
                    onTap: () => _interactWithPet('Le diste mucho amor a $petName', 5, '💖'),
                  ),
                  _buildCareButton(
                    emoji: '🎾',
                    label: 'Jugar',
                    xp: '+15 XP',
                    onTap: () => _interactWithPet('Jugaron juntos con $petName', 15, '🎾'),
                  ),
                  _buildCareButton(
                    emoji: '🛁',
                    label: 'Bañar',
                    xp: '+10 XP',
                    onTap: () => _interactWithPet('Dejaste a $petName limpio', 10, '🛁'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCareButton({
    required String emoji,
    required String label,
    required String xp,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE3E8), width: 1.2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            Text(xp, style: const TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
