import 'package:flutter/material.dart';
import 'package:jti_reports/core/constants/app_constants.dart';
import 'package:jti_reports/core/utils/validators.dart';
import 'package:jti_reports/core/utils/error_handler.dart';
import 'package:jti_reports/core/widgets/custom_text_field.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/features/auth/services/auth_service.dart';
import 'package:jti_reports/features/auth/pages/forgot_password_page.dart';
import 'package:jti_reports/features/home/pages/admin_page.dart';
import '../../../main.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Controller untuk animasi
  late AnimationController _controllerAnimasi;
  late Animation<double> _animasiFade;
  late Animation<double> _animasiScale;
  late Animation<Offset> _animasiSlide;

  // Controller untuk text field
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // Service dan state
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordTerlihat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inisialisasiAnimasi();
  }

  @override
  void dispose() {
    _controllerAnimasi.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  // ============ METHOD ANIMASI ============
  void _inisialisasiAnimasi() {
    _controllerAnimasi = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _animasiFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controllerAnimasi, curve: Curves.easeInOut),
    );

    _animasiScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controllerAnimasi, curve: Curves.elasticOut),
    );

    _animasiSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controllerAnimasi, curve: Curves.easeOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerAnimasi.forward();
    });
  }

  // ============ METHOD BISNIS LOGIC ============
  void _toggleVisibilitasPassword() {
    setState(() {
      _passwordTerlihat = !_passwordTerlihat;
    });
  }

  Future<void> _prosesLogin() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      _tampilkanSnackbar("Harap perbaiki kesalahan di form", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userModel = await _authService.signInWithEmail(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (userModel != null) {
        if (!userModel.emailVerified) {
          _tampilkanSnackbar(
            "Email belum diverifikasi! Cek email Anda.",
            Colors.orange,
          );
          await _authService.signOut();
          return;
        }

        _tampilkanSnackbar("Login berhasil!", Colors.green);

        if (userModel.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomePage(onTabChange: (int index) {}),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.getFriendlyErrorMessage(e);
      });
      _tampilkanSnackbar(_errorMessage!, Colors.red);
    }
  }

  Future<void> _prosesGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userModel = await _authService.signInWithGoogle();

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (userModel != null) {
        _tampilkanSnackbar("Login dengan Google berhasil!", Colors.green);

        if (userModel.role == AppConstants.adminRole) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminHomePage(onTabChange: (int index) {}),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.getFriendlyErrorMessage(e);
      });

      if (!_errorMessage!.toLowerCase().contains('dibatalkan')) {
        _tampilkanSnackbar(_errorMessage!, Colors.red);
      }
    }
  }

  void _navigateToLupaPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  void _navigateToDaftar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _tampilkanSnackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleFieldSubmitted(String value) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.focusedChild!.hasPrimaryFocus) {
      currentFocus.nextFocus();
    }
  }

  // ============ METHOD BUILD WIDGET ============
  Widget _buildHeader() {
    return FadeTransition(
      opacity: _animasiFade,
      child: ScaleTransition(
        scale: _animasiScale,
        child: Image.asset(
          'lib/images/logo.png',
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildJudul() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: Column(
          children: [
            Text(
              'Selamat Datang Kembali!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan masuk ke akun Anda',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLogin() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _controllerEmail,
            hintText: 'Alamat Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validasiEmail,
            fadeAnimation: _animasiFade,
            slideAnimation: _animasiSlide,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: _handleFieldSubmitted,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _controllerPassword,
            hintText: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: _passwordTerlihat,
            onToggleVisibility: _toggleVisibilitasPassword,
            validator: Validators.validasiPassword,
            fadeAnimation: _animasiFade,
            slideAnimation: _animasiSlide,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _prosesLogin(),
          ),
        ],
      ),
    );
  }

  Widget _buildTombolLupaPassword() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _navigateToLupaPassword,
            child: Text(
              'Lupa Password?',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTombolLogin() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: LoadingButton(
          isLoading: _isLoading,
          text: 'Masuk',
          onPressed: _prosesLogin,
          backgroundColor: Colors.blue[800]!,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTombolGoogleSignIn() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: LoadingButton(
          isLoading: _isLoading,
          text: 'Lanjutkan dengan Google',
          onPressed: _prosesGoogleSignIn,
          backgroundColor: Colors.white,
          textColor: Colors.grey[800]!,
          isGoogleButton: true,
          icon: Image.asset(
            'lib/images/google.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildPembatasAtau() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Atau lanjutkan dengan',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Belum punya akun? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            GestureDetector(
              onTap: _navigateToDaftar,
              child: Text(
                'Daftar',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildJudul(),
                        const SizedBox(height: 30),
                        _buildFormLogin(),
                        const SizedBox(height: 20),
                        _buildTombolLupaPassword(),
                        const SizedBox(height: 25),
                        _buildTombolLogin(),
                        const SizedBox(height: 40),
                        _buildPembatasAtau(),
                        const SizedBox(height: 20),
                        _buildTombolGoogleSignIn(),
                        const SizedBox(height: 30),
                        _buildFooter(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
