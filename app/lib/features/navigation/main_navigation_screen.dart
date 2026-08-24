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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final couple = Provider.of<CoupleProvider>(context, listen: false);

      if (auth.currentUser != null) {
        couple.initCouple(
          userId: auth.currentUser!['id'],
          coupleId: auth.coupleId,
          onPartnerMood: (mood, icon) {
            auth.updatePartnerMood(mood, icon);
          },
          onPartnerOnline: (online) {
            auth.updatePartnerPresence(online);
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRose.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryRose,
              unselectedItemColor: AppTheme.textMuted,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded),
                  label: 'Rincón',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_rounded),
                  label: 'Sparks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.photo_library_rounded),
                  label: 'Recuerdos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_rounded),
                  label: 'Citas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.mark_email_unread_rounded),
                  label: 'Cápsula',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
