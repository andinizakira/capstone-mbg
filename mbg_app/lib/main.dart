/// main.dart
/// ==========
/// Entry point aplikasi Flutter MBG Recommendation System.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'input_screen.dart';
import 'screens/riwayat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cek apakah onboarding sudah pernah dilihat
  final prefs = await SharedPreferences.getInstance();

  // ★ TODO: Hapus 2 baris ini setelah selesai testing ★
  await prefs.setBool('onboarding_done', false);
  await AuthService.clearSession();

  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

  // Cek apakah user sudah login (punya session token)
  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(MbgApp(isLoggedIn: loggedIn, onboardingDone: onboardingDone));
}

class MbgApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool onboardingDone;
  const MbgApp({super.key, required this.isLoggedIn, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    // Tentukan halaman awal berdasarkan status onboarding & login
    Widget homeScreen;
    if (!onboardingDone) {
      homeScreen = const OnboardingScreen();
    } else if (isLoggedIn) {
      homeScreen = const MainScreen();
    } else {
      homeScreen = const LoginScreen();
    }

    return MaterialApp(
      title: 'Rekomendasi Menu MBG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF66BB6A),
          surface: const Color(0xFF111111),
          error: const Color(0xFFEF5350),
        ),
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        cardTheme: const CardTheme(
          color: const Color(0xFF111111),
          elevation: 1,
        ),
      ),
      home: homeScreen,
    );
  }
}

// ── Widget MainScreen dengan Bottom Navigation sederhana ──────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const InputScreen(),
      const RiwayatScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
