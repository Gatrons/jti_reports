import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jti_reports/features/lapor/models/laporan_model.dart';

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
                  child: FutureBuilder<List<LaporanModel>>(
                    future: _getTodayCreatedReports(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final reports = snapshot.data ?? [];
                      if (reports.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada laporan baru hari ini'),
                        );
                      }
                      return ListView.builder(
                        controller: controller,
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[50],
                              child: Icon(
                                Icons.report,
                                color: Colors.orange[800],
                              ),
                            ),
                            title: Text("Laporan Baru: ${report.jenisKerusakan}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tingkat Keparahan: ${report.tingkatKeparahan}"),
                                Text("Status: ${report.status}"),
                              ],
                            ),
                            trailing: Text(
                              DateFormat('HH:mm').format(report.timestamp ?? DateTime.now()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
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

  static Future<List<LaporanModel>> _getTodayCreatedReports() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = FirebaseFirestore.instance
        .collection('reports')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => LaporanModel.fromDoc(doc)).toList();
  }
}