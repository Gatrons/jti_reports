import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Untuk animasi emoji
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Lapor Fasilitas Rusak',
      description:
          'Laporkan fasilitas yang rusak, kotor, atau tidak layak pakai di lingkungan JTI. '
          'Isi detail laporan, pilih lokasi, dan unggah foto agar bisa segera ditindaklanjuti.',
      emoji: '🛠️',
    ),
    _OnboardingData(
      title: 'Pantau Progres Laporan',
      description:
          'Pantau status laporanmu mulai dari diajukan, diproses, hingga selesai. '
          'Riwayat laporan tersimpan rapi sehingga kamu tahu sejauh mana tindak lanjutnya.',
      emoji: '📊',
    ),
    _OnboardingData(
      title: 'Bersama Jaga Kampus Nyaman',
      description:
          'Setiap laporan yang kamu kirim membantu menjaga JTI tetap aman dan nyaman untuk belajar. '
          'Mari berkolaborasi menjaga fasilitas kampus.',
      emoji: '🤝',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });

    // Inisialisasi AnimationController untuk emoji
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack, // Kurva yang lebih "fun"
      ),
    );
    // Jalankan animasi setiap kali halaman berubah
    _pageController.addListener(_handlePageChangeAnimation);
    _animationController.forward(); // Animasi awal
  }

  void _handlePageChangeAnimation() {
    _animationController.reset();
    _animationController.forward();
  }


  @override
  void dispose() {
    _pageController.removeListener(_handlePageChangeAnimation);
    _pageController.dispose();
    _animationController.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warna dari HEX string
    final Color deepPurpleHex = const Color.fromARGB(255, 156, 54, 193);
    final Color darkPurpleHex = const Color.fromARGB(255, 161, 59, 198);

    // Definisikan ColorScheme untuk warna aksen dan teks.
    // Brightness.light digunakan untuk teks hitam default di atas latar putih.
    final ColorScheme customColorScheme = ColorScheme(
      brightness: Brightness.light, 
      // Primary akan digunakan untuk highlight (indicator, sebagian bayangan)
      primary: deepPurpleHex, 
      onPrimary: Colors.white, // Teks di atas primary (jika primary dipakai di tombol)
      
      // Secondary digunakan untuk tombol 'Lanjut' yang putih
      secondary: Colors.white, 
      onSecondary: Colors.black, // Teks di atas secondary (tombol lanjut)
      
      // Teks utama akan Putih agar kontras dengan gradient
      onBackground: Colors.white, 
      background: deepPurpleHex, // Ini hanya fallback jika tidak ada gradient
      
      error: Colors.redAccent,
      onError: Colors.white,
      surface: deepPurpleHex,
      onSurface: Colors.white,
    );
    
    final theme = Theme.of(context).copyWith(colorScheme: customColorScheme);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // **1. LINEAR GRADIENT DENGAN WARNA SPESIFIK & CERAH**
          gradient: LinearGradient(
            // Menggunakan warna dari HEX dan menambahkan Colors.purpleAccent di tengah
            colors: [
              deepPurpleHex, 
              Colors.purpleAccent.shade100, // Warna lebih terang di tengah
              darkPurpleHex,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0], // Posisi masing-masing warna
          ),
        ),
        
        child: SafeArea(
          child: Column(
            children: [
              // Tombol Lewati
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground, // Putih
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    _animationController.reset(); // Reset animasi saat halaman berubah
                    _animationController.forward(); // Mulai animasi baru
                  },
                  itemBuilder: (context, index) {
                    final data = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ilustrasi (emoji) dengan animasi ScaleTransition
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onBackground, // Latar belakang lingkaran Putih
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2), // Bayangan lebih umum
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  data.emoji,
                                  style: const TextStyle(fontSize: 100), 
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Judul
                          Text(
                            data.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onBackground, // Putih
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Deskripsi
                          Text(
                            data.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.9), // Putih transparan
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Indicator bulat kecil
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentPage == index ? 24 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      // Indikator menggunakan primary (deepPurpleHex)
                      color: _currentPage == index
                          ? theme.colorScheme.onBackground // Warna putih agar menonjol di gradient
                          : theme.colorScheme.onBackground.withOpacity(0.4),
                    ),
                  ),
                ),
              ),

              // Tombol Lanjut / Mulai
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isLastPage) {
                        _goToLogin();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.fastOutSlowIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      // **2. TOMBOL LANJUT WARNA PUTIH DENGAN FONT HITAM**
                      backgroundColor: theme.colorScheme.secondary, // Warna Putih
                      foregroundColor: theme.colorScheme.onSecondary, // Warna Hitam
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isLastPage ? 'Mulai Lapor' : 'Lanjut',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String emoji;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.emoji,
  });
}