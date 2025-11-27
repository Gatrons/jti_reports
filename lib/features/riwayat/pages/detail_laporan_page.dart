import 'package:flutter/material.dart';

class DetailLaporanPage extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;

  const DetailLaporanPage({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "Gambar Pendukung",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildInfo("Judul Laporan", title),
          _buildInfo("Tanggal", date),
          _buildInfo("Status", status, color: statusColor),
          _buildInfo(
            "Deskripsi",
            "Flush closet tidak berfungsi dengan baik dan menyebabkan kebocoran air.",
          ),
          _buildInfo("Lokasi", "Gedung TI Lantai 5 - Toilet Pria"),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
          ),
        ],
      ),
    );
  }
}
