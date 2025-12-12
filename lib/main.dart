import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jti_reports/features/admin/pages/admin_main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:jti_reports/core/services/notification_service.dart';

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

const supabaseUrl = 'https://qhugkqivkewxvucylozc.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFodWdrcWl2a2V3eHZ1Y3lsb3pjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwMjA0NzgsImV4cCI6MjA4MDU5NjQ3OH0.PtOd-TDpiShoUU7TKXeEwQI0j4NNtyEAzFINAxcUExk';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp();
  await supabase.Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

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
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/email-verification': (context) => const EmailVerificationPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
        '/help': (context) => const HelpPage(),
      },
    );
  }
}

/// Widget untuk handle authentication state
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
          return const OnboardingPage();
        }

        if (!user.emailVerified) {
          return const EmailVerificationPage();
        }

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserRoleFromFirestore(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final userData = roleSnapshot.data;
            final role = (userData?['role'] ?? 'user').toString();

            if (role == 'admin') {
              return const _AdminGate();
            } else {
              return const MainPage();
            }
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserRoleFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) return doc.data();
      return {'role': 'user'};
    } catch (e) {
      print('Error getting user role from Firestore: $e');
      return {'role': 'user'};
    }
  }
}

/// ✅ Gate khusus admin supaya init notification tidak kepanggil berulang saat build
class _AdminGate extends StatefulWidget {
  const _AdminGate();

  @override
  State<_AdminGate> createState() => _AdminGateState();
}

class _AdminGateState extends State<_AdminGate> {
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    // 🔔 Init notification (subscribe topic admin, get token, listeners)
    // Tidak perlu await agar tidak nge-block UI
    NotificationService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return const AdminMainPage();
  }
}

/// Splash Screen untuk loading
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
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
                    color: Colors.blue[800]!.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60,
                color: Colors.blue[800],
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
    final List<Widget> pages = [
      RiwayatPage(onTabChange: _changeTab),
      HomePage(onTabChange: _changeTab),
      TambahlaporanPage(onTabChange: _changeTab),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
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
