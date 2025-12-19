import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jti_reports/features/lapor/models/laporan_model.dart';
import 'package:jti_reports/core/widgets/reports/reports_list.dart';

class AdminNotificationModal {
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
                  "Laporan Baru Hari Ini",
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
                        future: _getTodayCreatedReports(),
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
                              final keparahan = data['tingkat_keparahan']?.toString() ?? '-';
                              final waktu = data['timestamp'] is Timestamp
                                  ? (data['timestamp'] as Timestamp).toDate()
                                  : DateTime.now();

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo[50],
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                title: Text("Laporan Baru: $jenis"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Tingkat Keparahan: $keparahan"),
                                  ],
                                ),
                                trailing: Text(
                                  DateFormat('HH:mm').format(waktu),
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

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getTodayCreatedReports() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs;
  }
}