import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/couple_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../home/screens/home_dashboard_screen.dart';
import '../daily_sparks/screens/daily_sparks_screen.dart';
import '../timeline/screens/timeline_screen.dart';
import '../bucket_list/screens/bucket_list_screen.dart';
import '../letters/screens/secret_letters_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bounceController;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    DailySparksScreen(),
    TimelineScreen(),
    BucketListScreen(),
    SecretLettersScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.favorite_rounded,     iconOff: Icons.favorite_border_rounded,     label: 'Rincón'),
    _NavItem(icon: Icons.auto_awesome_rounded,  iconOff: Icons.auto_awesome_outlined,       label: 'Sparks'),
    _NavItem(icon: Icons.photo_library_rounded, iconOff: Icons.photo_library_outlined,      label: 'Recuerdos'),
    _NavItem(icon: Icons.checklist_rounded,     iconOff: Icons.check_box_outline_blank_rounded, label: 'Citas'),
    _NavItem(icon: Icons.mail_rounded,          iconOff: Icons.mail_outline_rounded,        label: 'Cápsula'),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth   = Provider.of<AuthProvider>(context, listen: false);
      final couple = Provider.of<CoupleProvider>(context, listen: false);
      if (auth.currentUser != null) {
        couple.initCouple(
          userId: auth.currentUser!['id'],
          coupleId: auth.coupleId,
          onPartnerMood: (mood, icon) => auth.updatePartnerMood(mood, icon),
          onPartnerOnline: (online) => auth.updatePartnerPresence(online),
        );
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _bounceController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ─── Floating Nav Bar ─────────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding + 12,
        top: 0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(
                color: AppTheme.primaryRose.withOpacity(0.15),
                width: 1.2,
              ),
              boxShadow: AppTheme.navShadow,
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                return Expanded(
                  child: _NavTabItem(
                    item: items[i],
                    selected: selected,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: selected
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 0)
            : EdgeInsets.zero,
        decoration: selected
            ? BoxDecoration(
                gradient: AppTheme.loveGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : null,
        child: selected
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 18, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1, end: 0)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.iconOff, size: 22, color: AppTheme.textMuted),
                ],
              ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.iconOff,
    required this.label,
  });
  final IconData icon;
  final IconData iconOff;
  final String label;
}
