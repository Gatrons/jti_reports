import 'package:flutter/material.dart';
import '../notifications/user_notifications_modal.dart';
import '../notifications/admin_notifications_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 4,
      centerTitle: true,

      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && user.email == 'atherosmurf@gmail.com') { // Cek role admin berdasarkan email
              AdminNotificationModal.show(context);
            } else {
              UserNotificationModal.show(context);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
