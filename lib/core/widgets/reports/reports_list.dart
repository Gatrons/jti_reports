import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jti_reports/features/riwayat/pages/detail_laporan_page.dart';

String formatTimestamp(dynamic timestamp) {
  try {
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else if (timestamp is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return timestamp?.toString() ?? '';
    }
    return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
  } catch (_) {
    return timestamp?.toString() ?? '';
  }
}

void navigateToDetailLaporan(BuildContext context, QueryDocumentSnapshot doc) {
  final data = (doc.data() as Map<String, dynamic>?) ?? {};
  final judul = data['jenis_kerusakan']?.toString() ?? 'Laporan tidak tersedia';
  final tanggal = formatTimestamp(data['timestamp']);
  final status = data['status']?.toString() ?? 'Diajukan';
  final warna = status.toLowerCase() == 'selesai'
      ? Colors.green
      : status.toLowerCase() == 'diproses'
          ? Colors.orange
          : Colors.redAccent;
  final deskripsi = data['deskripsi']?.toString() ?? 'Deskripsi tidak tersedia';
  final keparahan = data['tingkat_keparahan'].toString();
  final Map<String, dynamic>? lokasi = (data['lokasi'] is Map)
      ? Map<String, dynamic>.from(data['lokasi'])
      : null;
  final mediaPaths = (data['media_paths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailLaporanPage(
        title: judul,
        date: tanggal,
        status: status,
        statusColor: warna,
        deskripsi: deskripsi,
        keparahan: keparahan,
        lokasi: lokasi,
        mediaPaths: mediaPaths,
        docId: doc.id,
      ),
    ),
  );
}

Widget buildReportCard(BuildContext context, QueryDocumentSnapshot doc,
    {void Function()? onTap}) {
  final data = (doc.data() as Map<String, dynamic>?) ?? {};
  final judul = data['jenis_kerusakan']?.toString() ?? 'Laporan';
  final timestamp = data['timestamp'];
  final tanggal = formatTimestamp(timestamp);
  final status = data['status']?.toString() ?? 'Diajukan';
  Color warna;
  switch (status.toLowerCase()) {
    case 'selesai':
      warna = Colors.green;
      break;
    case 'diproses':
      warna = Colors.orange;
      break;
    default:
      warna = Colors.redAccent;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.indigo.shade200.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: warna.withOpacity(0.2),
            child: Icon(Icons.report, color: warna, size: 28),
          ),
          title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(tanggal),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: warna.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: warna, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

class ReportsList extends StatelessWidget {
  final String? userId;
  final bool clientSort; // jika true, urutkan di client tanpa orderBy di query
  final void Function(QueryDocumentSnapshot doc)? onCardTap;

  const ReportsList({Key? key, this.userId, this.clientSort = false, this.onCardTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Text('Silakan login untuk melihat riwayat laporan');
    }

    final stream = FirebaseFirestore.instance
        .collection('reports')
        .where('user_id', isEqualTo: uid)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final err = snapshot.error;
          return Text('Terjadi error: $err');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('Belum ada laporan');
        }

        final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
        if (clientSort) {
          docs.sort((a, b) {
            final ta = a['timestamp'] is Timestamp ? (a['timestamp'] as Timestamp).toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            final tb = b['timestamp'] is Timestamp ? (b['timestamp'] as Timestamp).toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            return tb.compareTo(ta);
          });
        }

        return Column(
          children: docs
              .map((doc) => buildReportCard(
                    context,
                    doc,
                    onTap: onCardTap != null
                        ? () => onCardTap!(doc)
                        : () => navigateToDetailLaporan(context, doc),
                  ))
              .toList(),
        );
      },
    );
  }
}