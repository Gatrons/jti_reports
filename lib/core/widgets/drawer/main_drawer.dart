import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:jti_reports/features/auth/services/auth_service.dart';
import 'package:jti_reports/features/auth/models/user_model.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Future<UserModel?> _loadUserModel() async {
    final authService = AuthService();
    final uid = authService.currentUserId;
    if (uid == null) return null;
    return authService.getUserData(uid);
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

                  // tutup dialog dulu
                  if (context.mounted) {
                    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: FutureBuilder<UserModel?>(
        future: _loadUserModel(),
        builder: (context, snapshot) {
          final userModel = snapshot.data;

          final displayName =
              userModel?.name ?? firebaseUser?.displayName ?? 'Pengguna';
          final email =
              userModel?.email ?? firebaseUser?.email ?? 'email@unknown.com';

          final photoUrl = userModel?.photoURL ?? firebaseUser?.photoURL;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue[800]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.blue[800],
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profil"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Pengaturan"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
