import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jti_reports/core/widgets/reports/reports_list.dart';

class UserNotificationModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Notifikasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child:
                      FutureBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      >(
                        future: _getTodayReports(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final docs = snapshot.data ?? [];
                          if (docs.isEmpty) {
                            return const Center(
                              child: Text('Tidak ada notifikasi hari ini'),
                            );
                          }

                          return ListView.builder(
                            controller: controller,
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data();

                              final jenis =
                                  data['jenis_kerusakan']?.toString() ?? '-';
                              final status = data['status']?.toString() ?? '-';
                              final updatedAt = data['updated_at'] is Timestamp
                                  ? (data['updated_at'] as Timestamp).toDate()
                                  : DateTime.now();

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo[50],
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                title: const Text("Laporan Anda diperbarui"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Laporan: $jenis"),
                                    Text("Status terbaru: $status"),
                                  ],
                                ),
                                trailing: Text(
                                  DateFormat('HH:mm').format(updatedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  navigateToDetailLaporan(context, doc);
                                },
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _getTodayReports() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('user_id', isEqualTo: uid)
        .where(
          'updated_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('updated_at', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('updated_at', descending: true)
        .get();

    return snapshot.docs;
  }
}
