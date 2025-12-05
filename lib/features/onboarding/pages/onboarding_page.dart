import 'package:flutter/material.dart';
import 'package:jti_reports/features/auth/pages/login_page.dart';
import 'package:jti_reports/core/constants/onboarding_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controllerHalaman = PageController();
  int _halamanSekarang = 0;

  late AnimationController _controllerAnimasi;
  late Animation<double> _animasiScale;

  @override
  void initState() {
    super.initState();
    _inisialisasiControllerHalaman();
    _inisialisasiAnimasi();
  }

  @override
  void dispose() {
    _controllerHalaman.removeListener(_handlePerubahanHalamanAnimasi);
    _controllerHalaman.dispose();
    _controllerAnimasi.dispose();
    super.dispose();
  }

  // ============ METHOD INISIALISASI ============
  void _inisialisasiControllerHalaman() {
    _controllerHalaman.addListener(() {
      if (_controllerHalaman.page != null) {
        setState(() {
          _halamanSekarang = _controllerHalaman.page!.round();
        });
      }
    });
  }

  void _inisialisasiAnimasi() {
    _controllerAnimasi = AnimationController(
      vsync: this,
      duration: OnboardingConstants.durasiAnimasi,
    );

    _animasiScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controllerAnimasi, curve: Curves.easeOutBack),
    );

    _controllerHalaman.addListener(_handlePerubahanHalamanAnimasi);
    _controllerAnimasi.forward();
  }

  void _handlePerubahanHalamanAnimasi() {
    _controllerAnimasi.reset();
    _controllerAnimasi.forward();
  }

  // ============ METHOD BISNIS LOGIC ============
  bool get _isHalamanTerakhir =>
      _halamanSekarang == OnboardingConstants.dataHalaman.length - 1;

  void _navigasiKeLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _handleTombolLanjut() {
    if (_isHalamanTerakhir) {
      _navigasiKeLogin();
    } else {
      _controllerHalaman.nextPage(
        duration: OnboardingConstants.durasiTransisiHalaman,
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  // ============ METHOD BUILD WIDGET ============
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildThemeData(),
      child: Scaffold(
        body: Container(
          decoration: _buildBackgroundDecoration(),
          child: SafeArea(
            child: Column(
              children: [
                _buildTombolLewati(),
                _buildAreaKonten(),
                _buildIndikatorHalaman(),
                _buildTombolLanjut(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: OnboardingConstants.warnaDeepPurple,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        background: OnboardingConstants.warnaDeepPurple,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: OnboardingConstants.warnaDeepPurple,
        onSurface: Colors.white,
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: OnboardingConstants.gradientWarna,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildTombolLewati() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topRight,
        child: TextButton(
          onPressed: _navigasiKeLogin,
          child: Text(
            OnboardingConstants.teksLewati,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaKonten() {
    return Expanded(
      child: PageView.builder(
        controller: _controllerHalaman,
        itemCount: OnboardingConstants.dataHalaman.length,
        onPageChanged: (index) {
          setState(() {
            _halamanSekarang = index;
          });
          _controllerAnimasi.reset();
          _controllerAnimasi.forward();
        },
        itemBuilder: (context, index) {
          final data = OnboardingConstants.dataHalaman[index];
          return _buildHalamanKonten(data);
        },
      ),
    );
  }

  Widget _buildHalamanKonten(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIlustrasiEmoji(data.emoji),
          const SizedBox(height: 40),
          _buildJudulHalaman(data.judul),
          const SizedBox(height: 16),
          _buildDeskripsiHalaman(data.deskripsi),
        ],
      ),
    );
  }

  Widget _buildIlustrasiEmoji(String emoji) {
    return ScaleTransition(
      scale: _animasiScale,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onBackground,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 100)),
        ),
      ),
    );
  }

  Widget _buildJudulHalaman(String judul) {
    return Text(
      judul,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onBackground,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDeskripsiHalaman(String deskripsi) {
    return Text(
      deskripsi,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildIndikatorHalaman() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        OnboardingConstants.dataHalaman.length,
        (index) => _buildBulletIndikator(index),
      ),
    );
  }

  Widget _buildBulletIndikator(int index) {
    return AnimatedContainer(
      duration: OnboardingConstants.durasiAnimasiIndikator,
      width: _halamanSekarang == index ? 24 : 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _halamanSekarang == index
            ? Theme.of(context).colorScheme.onBackground
            : Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
      ),
    );
  }

  Widget _buildTombolLanjut() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _handleTombolLanjut,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isHalamanTerakhir
                ? OnboardingConstants.teksTombolMulai
                : OnboardingConstants.teksTombolLanjut,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
