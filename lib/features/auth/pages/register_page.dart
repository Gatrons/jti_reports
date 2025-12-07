import 'package:flutter/material.dart';
import 'package:jti_reports/core/constants/app_constants.dart';
import 'package:jti_reports/core/utils/validators.dart';
import 'package:jti_reports/core/utils/error_handler.dart';
import 'package:jti_reports/core/widgets/custom_text_field.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/features/auth/services/auth_service.dart';
import 'package:jti_reports/features/home/pages/admin_page.dart';
import 'package:jti_reports/main.dart';
import '../models/user_model.dart';
import '../pages/email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // Controller untuk animasi
  late AnimationController _controllerAnimasi;
  late Animation<double> _animasiFade;
  late Animation<double> _animasiScale;
  late Animation<Offset> _animasiSlide;

  // Controller untuk text field
  final TextEditingController _controllerNamaLengkap = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerKonfirmasiPassword =
      TextEditingController();

  // Service dan state
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordTerlihat = false;
  bool _konfirmasiPasswordTerlihat = false;
  bool _setujuSyarat = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inisialisasiAnimasi();
  }

  @override
  void dispose() {
    _controllerAnimasi.dispose();
    _controllerNamaLengkap.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerKonfirmasiPassword.dispose();
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
  void _tombolKembali() {
    if (!_isLoading) {
      Navigator.pop(context);
    }
  }

  void _toggleVisibilitasPassword() {
    setState(() {
      _passwordTerlihat = !_passwordTerlihat;
    });
  }

  void _toggleVisibilitasKonfirmasiPassword() {
    setState(() {
      _konfirmasiPasswordTerlihat = !_konfirmasiPasswordTerlihat;
    });
  }

  void _togglePersetujuanSyarat() {
    setState(() {
      _setujuSyarat = !_setujuSyarat;
      _errorMessage = null; // Clear error ketika checkbox di-toggle
    });
  }

  Future<void> _prosesRegistrasi() async {
    // Reset error message
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      _tampilkanSnackbar("Harap perbaiki kesalahan di form", Colors.orange);
      return;
    }

    if (!_setujuSyarat) {
      setState(
        () => _errorMessage = "Anda harus menyetujui syarat & ketentuan",
      );
      _tampilkanSnackbar(
        "Anda harus menyetujui syarat & ketentuan",
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.daftarUser(
        namaLengkap: _controllerNamaLengkap.text.trim(),
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text.trim(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      _tampilkanSnackbar(AppConstants.successRegistration, Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationPage()),
      );
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
        _tampilkanSnackbar(AppConstants.successGoogleSignIn, Colors.green);

        // Navigate ke home page berdasarkan role
        _navigateBasedOnRole(userModel);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.getFriendlyErrorMessage(e);
      });

      // Jangan tampilkan snackbar untuk error cancellation
      if (!_errorMessage!.contains('dibatalkan')) {
        _tampilkanSnackbar(_errorMessage!, Colors.red);
      }
    }
  }

  void _navigateBasedOnRole(UserModel userModel) {
    // Contoh navigasi berdasarkan role
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
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    }
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
  Widget _buildTombolKembali() {
    return Positioned(
      top: 0,
      left: 0,
      child: SlideTransition(
        position: _animasiSlide,
        child: FadeTransition(
          opacity: _animasiFade,
          child: IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: _isLoading ? Colors.grey : Colors.deepPurple,
              ),
            ),
            onPressed: _isLoading ? null : _tombolKembali,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: FadeTransition(
          opacity: _animasiFade,
          child: ScaleTransition(
            scale: _animasiScale,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
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
              'Buat Akun',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Isi detail Anda untuk membuat akun',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
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
                'Atau daftar dengan email',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRegistrasi() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _controllerNamaLengkap,
            hintText: 'Nama Lengkap',
            icon: Icons.person_outline,
            validator: Validators.validasiNamaLengkap,
            fadeAnimation: _animasiFade,
            slideAnimation: _animasiSlide,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: _handleFieldSubmitted,
          ),
          const SizedBox(height: 15),
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
          const SizedBox(height: 15),
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
            textInputAction: TextInputAction.next,
            onFieldSubmitted: _handleFieldSubmitted,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: _controllerKonfirmasiPassword,
            hintText: 'Konfirmasi Password',
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: _konfirmasiPasswordTerlihat,
            onToggleVisibility: _toggleVisibilitasKonfirmasiPassword,
            validator: (value) => Validators.validasiKonfirmasiPassword(
              _controllerPassword.text,
              value,
            ),
            fadeAnimation: _animasiFade,
            slideAnimation: _animasiSlide,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _prosesRegistrasi(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxSyarat() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _isLoading ? null : _togglePersetujuanSyarat,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _setujuSyarat ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _setujuSyarat
                              ? Colors.deepPurple
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: _setujuSyarat
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _togglePersetujuanSyarat,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Saya menyetujui ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: ' dan ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null &&
                  _errorMessage!.contains('syarat')) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTombolDaftar() {
    return SlideTransition(
      position: _animasiSlide,
      child: FadeTransition(
        opacity: _animasiFade,
        child: LoadingButton(
          isLoading: _isLoading,
          text: 'Buat Akun',
          onPressed: _prosesRegistrasi,
          backgroundColor: Colors.deepPurple,
          textColor: Colors.white,
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
              "Sudah punya akun? ",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            GestureDetector(
              onTap: _isLoading ? null : _tombolKembali,
              child: Text(
                'Masuk',
                style: TextStyle(
                  color: _isLoading ? Colors.grey : Colors.deepPurple,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Stack(children: [_buildTombolKembali(), _buildHeader()]),
                  const SizedBox(height: 40),
                  _buildJudul(),
                  const SizedBox(height: 30),

                  // Google Sign In Button
                  _buildTombolGoogleSignIn(),
                  const SizedBox(height: 30),

                  // Pembatas
                  _buildPembatasAtau(),
                  const SizedBox(height: 30),

                  // Form Registrasi Email
                  _buildFormRegistrasi(),
                  const SizedBox(height: 20),

                  // Checkbox Syarat
                  _buildCheckboxSyarat(),
                  const SizedBox(height: 25),

                  // Tombol Daftar
                  _buildTombolDaftar(),
                  const SizedBox(height: 30),

                  // Footer
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
