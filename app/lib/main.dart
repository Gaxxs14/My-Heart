import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/couple_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/pairing/screens/pairing_screen.dart';
import 'features/navigation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyHeartApp());
}

class MyHeartApp extends StatelessWidget {
  const MyHeartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => CoupleProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'My Heart',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const AuthGateway(),
          );
        },
      ),
    );
  }
}

class AuthGateway extends StatelessWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final couple = Provider.of<CoupleProvider>(context);

    if (auth.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF0F3), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: Color(0xFFFF5E7E), size: 60),
                SizedBox(height: 16),
                CircularProgressIndicator(color: Color(0xFFFF5E7E)),
              ],
            ),
          ),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    if (auth.isDemoMode) {
      return const MainNavigationScreen();
    }

    if (!auth.isPaired && !couple.isPaired) {
      return const PairingScreen();
    }

    return const MainNavigationScreen();
  }
}
