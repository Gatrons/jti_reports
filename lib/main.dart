import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import halaman auth
import 'package:jti_reports/features/auth/pages/login_page.dart';
import 'package:jti_reports/features/auth/pages/register_page.dart';
import 'package:jti_reports/features/auth/pages/email_verification_page.dart';
import 'package:jti_reports/features/home/pages/home_page.dart';

// Import halaman lainnya
import 'package:jti_reports/features/onboarding/pages/onboarding_page.dart';
import 'package:jti_reports/features/profile/pages/profile_page.dart';
import 'package:jti_reports/features/settings/pages/change_password_page.dart';
import 'package:jti_reports/features/settings/pages/help_page.dart';
import 'package:jti_reports/features/settings/pages/privacy_policy_page.dart';
import 'package:jti_reports/features/settings/pages/settings_page.dart';
import 'features/riwayat/pages/riwayat_page.dart';
import 'features/lapor/pages/tambah_laporan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null).then((_) {});
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JTI Report App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(), // Gunakan AuthWrapper untuk handle auth state
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/email-verification': (context) => const EmailVerificationPage(),
        // '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/help': (context) => const HelpPage(),
      },
    );
  }
}

// Widget untuk handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          // User belum login, arahkan ke onboarding
          return const OnboardingPage();
        }

        // User sudah login, cek email verification
        if (!user.emailVerified) {
          return const EmailVerificationPage();
        }

        // User sudah login dan email terverifikasi, arahkan ke main page
        return const MainPage();
      },
    );
  }
}

// Splash Screen untuk loading
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withAlpha(76),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 60,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'JTI Reports',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      RiwayatPage(onTabChange: _changeTab),
      HomePage(onTabChange: _changeTab),
      TambahlaporanPage(onTabChange: _changeTab),
    ];
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.blue[800]!,
        buttonBackgroundColor: Colors.blue[800],
        height: 60,
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.home, size: 35, color: Colors.white),
          Icon(Icons.add_circle_outline, size: 30, color: Colors.white),
        ],
        onTap: (index) => _changeTab(index),
      ),
    );
  }
}
