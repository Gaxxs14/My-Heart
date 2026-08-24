import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    DailySparksScreen(),
    TimelineScreen(),
    BucketListScreen(),
    SecretLettersScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(
      icon: Icons.favorite_rounded,
      iconOff: Icons.favorite_border_rounded,
      label: 'Inicio',
    ),
    _NavItem(
      icon: Icons.auto_awesome_rounded,
      iconOff: Icons.auto_awesome_outlined,
      label: 'Chispas',
    ),
    _NavItem(
      icon: Icons.photo_library_rounded,
      iconOff: Icons.photo_library_outlined,
      label: 'Recuerdos',
    ),
    _NavItem(
      icon: Icons.checklist_rounded,
      iconOff: Icons.check_box_outline_blank_rounded,
      label: 'Citas',
    ),
    _NavItem(
      icon: Icons.mail_rounded,
      iconOff: Icons.mail_outline_rounded,
      label: 'Cartas',
    ),
  ];

  @override
  void initState() {
    super.initState();
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

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false, // Ensures bottom buttons and content are NEVER covered
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _ClearNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ─── High-Contrast Crystal-Clear Nav Bar ─────────────────────────────────────

class _ClearNavBar extends StatelessWidget {
  const _ClearNavBar({
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryRose.withOpacity(0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding, top: 6),
      height: 64 + bottomPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          final item = items[i];

          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              splashColor: AppTheme.softPink,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryRose.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      selected ? item.icon : item.iconOff,
                      size: 24,
                      color: selected
                          ? AppTheme.primaryRose
                          : const Color(0xFF6B5560),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? AppTheme.primaryRose
                          : const Color(0xFF6B5560),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
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
