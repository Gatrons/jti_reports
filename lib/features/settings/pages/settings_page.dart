import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: _buildBody(context),
      backgroundColor: Colors.indigo[50],
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSectionHeader("Akun"),
        _buildMenuItem(
          title: "Profil Saya",
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
        _buildMenuItem(title: "Username", trailingText: "anonim", onTap: null),
        _buildMenuItem(
          title: "Email",
          trailingText: "anonim@gmail.com",
          onTap: null,
        ),
        _buildMenuItem(
          title: "Ganti Sandi",
          onTap: () {
            Navigator.pushNamed(context, '/change-password');
          },
        ),

        _buildSectionHeader("Lainnya"),
        _buildMenuItem(title: "Kebijakan & Privasi", onTap: () {
          Navigator.pushNamed(context, '/privacy-policy');
        }),
        _buildMenuItem(title: "Bantuan", onTap: () {
          Navigator.pushNamed(context, '/help');
        }),
        Container(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Keluar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  }) {
    bool isInfoOnly = onTap == null;

    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            if (!isInfoOnly) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ],
        ),

        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              onPressed: () async {
                try {
                  final googleSignIn = GoogleSignIn();

                  if (await googleSignIn.isSignedIn()) {
                    await googleSignIn.signOut();
                  }

                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
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
