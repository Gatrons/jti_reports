import 'package:flutter/material.dart';
import 'detail_laporan_page.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pelaporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 12),

            _buildReportCard(
              context: context,
              title: "Kerusakan Toilet",
              date: "10 November 2025",
              status: "Diajukan",
              statusColor: Colors.redAccent,
              icon: Icons.report,
            ),

            _buildReportCard(
              context: context,
              title: "Lampu Mati",
              date: "12 November 2025",
              status: "Diproses",
              statusColor: Colors.orangeAccent,
              icon: Icons.report,
            ),

            _buildReportCard(
              context: context,
              title: "AC Tidak Dingin",
              date: "14 November 2025",
              status: "Selesai",
              statusColor: Colors.green,
              icon: Icons.report,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade200.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailLaporanPage(
                title: title,
                date: date,
                status: status,
                statusColor: statusColor,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(icon, color: statusColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
