import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:jti_reports/pages/tambah_laporan_page.dart';

// Import semua halaman
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/riwayat_page.dart';
import 'pages/onboarding3_page.dart';
import 'pages/tambah_laporan_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      // Tema global agar konsisten Deep Purple
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        // Arahkan route '/home' ke MainPage agar navigasi bawah muncul
        '/home': (context) => const MainPage(), 
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Default index 1 agar saat login langsung ke Home (Tengah)
  int _selectedIndex = 1;

  // Daftar Halaman untuk Navigasi Bawah
  final List<Widget> _pages = const [
    RiwayatPage(),        // Index 0: Kiri
    HomePage(),           // Index 1: Tengah (Default)
    TambahlaporanPage(),  // Index 2: Kanan (Halaman Laporan Baru)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBody: true membuat konten halaman memanjang sampai ke belakang navbar
      // sehingga navbar terlihat transparan/mengambang di atas konten
      extendBody: true, 
      
      body: _pages[_selectedIndex], // Menampilkan halaman sesuai index yang dipilih
      
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent, // Transparan agar background halaman terlihat
        color: Colors.deepPurple, // Warna navbar
        buttonBackgroundColor: Colors.deepPurple, // Warna tombol bulat yang aktif
        height: 60,
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.history, size: 30, color: Colors.white), // Ikon Riwayat
          Icon(Icons.home, size: 35, color: Colors.white),    // Ikon Home
          Icon(Icons.add_circle_outline, size: 30, color: Colors.white), // Ikon Tambah Laporan
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}