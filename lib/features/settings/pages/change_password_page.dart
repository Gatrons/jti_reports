import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jti_reports/core/widgets/custom_text_field.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/core/utils/validators.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();

  bool _visibleOld = false;
  bool _visibleNew = false;
  bool _visibleConfirm = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      if (user.providerData.any((p) => p.providerId != 'password')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Akun ini login menggunakan Google. "
              "Password tidak dapat diubah.",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPass.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(_newPass.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Terjadi kesalahan";

      if (e.code == 'wrong-password') msg = "Password lama salah";
      if (e.code == 'invalid-credential') msg = "Password lama salah";
      if (e.code == 'user-mismatch') msg = "Akun tidak valid";
      if (e.code == 'weak-password') msg = "Password baru terlalu lemah";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Ganti Sandi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Untuk merubah kata sandi mohon lengkapi formulir dibawah ini',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildForm(),
          ],
        ),
      ),
      backgroundColor: Colors.indigo[50],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _oldPass,
            hintText: "Password Lama",
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: _visibleOld,
            onToggleVisibility: () {
              setState(() => _visibleOld = !_visibleOld);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password lama tidak boleh kosong";
              }
              return null;
            },
          ),

          const SizedBox(height: 15),

          CustomTextField(
            controller: _newPass,
            hintText: "Password Baru",
            icon: Icons.lock_reset_outlined,
            isPassword: true,
            isVisible: _visibleNew,
            onToggleVisibility: () {
              setState(() => _visibleNew = !_visibleNew);
            },
            validator: Validators.validasiPassword,
          ),

          const SizedBox(height: 15),

          CustomTextField(
            controller: _confirmPass,
            hintText: "Konfirmasi Password Baru",
            icon: Icons.lock_outline,
            isPassword: true,
            isVisible: _visibleConfirm,
            onToggleVisibility: () {
              setState(() => _visibleConfirm = !_visibleConfirm);
            },
            validator: (value) {
              if (value != _newPass.text) {
                return "Konfirmasi password tidak sesuai";
              }
              return null;
            },
          ),

          const SizedBox(height: 25),

          LoadingButton(
            isLoading: _isLoading,
            text: "Simpan Perubahan",
            onPressed: _changePassword,
            backgroundColor: Colors.blue[800]!,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
