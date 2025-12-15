import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:jti_reports/features/auth/services/auth_service.dart';
import 'package:jti_reports/features/auth/models/user_model.dart';

class AdminSettingPage extends StatelessWidget {
  final void Function(int index) onTabChange;
  const AdminSettingPage({super.key, required this.onTabChange});

  Future<UserModel?> _loadUserModel() async {
    final authService = AuthService();
    final uid = authService.currentUserId;
    if (uid == null) return null;
    return authService.getUserData(uid);
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Pengaturan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      backgroundColor: Colors.indigo[50],
      body: FutureBuilder<UserModel?>(
        future: _loadUserModel(),
        builder: (context, snapshot) {
          final userModel = snapshot.data;
          final displayName =
              userModel?.name ?? firebaseUser?.displayName ?? 'Pengguna';
          final email =
              userModel?.email ?? firebaseUser?.email ?? 'email@unknown.com';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildSectionHeader("Akun"),
              _buildMenuItem(
                title: "Profil Saya",
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              _buildMenuItem(title: "Nama", trailingText: displayName),
              _buildMenuItem(title: "Email", trailingText: email),
              _buildMenuItem(
                title: "Ganti Sandi",
                onTap: () => Navigator.pushNamed(context, '/change-password'),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader("Bantuan"),
              _buildMenuItem(
                title: "Pusat Bantuan",
                onTap: () => Navigator.pushNamed(context, '/help'),
              ),
              _buildMenuItem(
                title: "Kebijakan Privasi",
                onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader("Keamanan"),
              _buildMenuItem(
                title: "Logout",
                trailingText: null,
                onTap: () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    String? trailingText,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final textColor = isDestructive ? Colors.red : Colors.black87;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
              ],
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final googleSignIn = GoogleSignIn();
                  if (await googleSignIn.isSignedIn()) {
                    await googleSignIn.signOut();
                  }

                  await FirebaseAuth.instance.signOut();

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(); // tutup dialog
                  }
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
