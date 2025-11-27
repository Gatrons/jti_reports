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
        '/home': (context) => const HomePage(),
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

  final List<Widget> _pages = const [
    RiwayatPage(), // Index 0: Kiri
    HomePage(), // Index 1: Tengah (Default)
    TambahlaporanPage(), // Index 2: Kanan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // appBar: AppBar(
      //   title: const Text('JTI Reports'),
      //   backgroundColor: Colors.deepPurple,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: _showLogoutDialog,
      //       tooltip: 'Logout',
      //     ),
      //   ],
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple,
        buttonBackgroundColor: Colors.deepPurple,
        height: 60,
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.home, size: 35, color: Colors.white),
          Icon(Icons.add_circle_outline, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigasi ke login page setelah logout
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
