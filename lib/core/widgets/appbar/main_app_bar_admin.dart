import 'package:flutter/material.dart';
import '../notifications/user_notifications_modal.dart';
import '../notifications/admin_notifications_modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainAppBarAdmin extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MainAppBarAdmin({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 4,
      centerTitle: true,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reports')
              .where('is_admin_read', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            final hasUnread =
                snapshot.hasData && snapshot.data!.docs.isNotEmpty;

            return IconButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null && user.email == 'admin@admin.com') {
                  AdminNotificationModal.show(context);

                  // 🔥 TANDAI SEMUA NOTIFIKASI SUDAH DIBACA
                  final unreadDocs = snapshot.data?.docs ?? [];
                  for (final doc in unreadDocs) {
                    await doc.reference.update({'is_admin_read': true});
                  }
                } else {
                  UserNotificationModal.show(context);
                }
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none, color: Colors.white),

                  /// 🔴 BULATAN MERAH
                  if (hasUnread)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
