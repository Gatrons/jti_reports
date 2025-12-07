import 'package:flutter/material.dart';
import 'package:jti_reports/core/widgets/appbar/main_app_bar.dart';
import 'package:jti_reports/core/widgets/drawer/main_drawer.dart';

class AdminHomePage extends StatelessWidget {
  final void Function(int index) onTabChange;

  const AdminHomePage({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const MainAppBar(title: 'Beranda'),
      backgroundColor: Colors.indigo[50],
      body: _buildBody(context),
    );
  }

  // ============ METHOD BUILD WIDGET ============

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildHeaderWelcome(),
          const SizedBox(height: 20),
          _buildStatusPerBulanSection(),
          const SizedBox(height: 30),
          _buildStatusPerTanggalSection(context),
        ],
      ),
    );
  }

  // ============ HEADER ============

  Widget _buildHeaderWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, Admin!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pantau status pelaporan fasilitas kampus.',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ],
    );
  }

  // ============ STATUS PER BULAN ============

  Widget _buildStatusPerBulanSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pelaporan per Bulan :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              _buildMonthChip('November 2025'),
            ],
          ),
          const SizedBox(height: 16),
          // 3 kartu ringkasan
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Diajukan',
                  count: 10,
                  gradientColors: const [Color(0xFFFFCDD2), Color(0xFFF8BBD0)],
                  titleColor: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Diproses',
                  count: 1,
                  gradientColors: const [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                  titleColor: const Color(0xFFF57C00),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Selesai',
                  count: 3,
                  gradientColors: const [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
                  titleColor: const Color(0xFF388E3C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required List<Color> gradientColors,
    required Color titleColor,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ STATUS PER TANGGAL / DAFTAR LAPORAN ============

  Widget _buildStatusPerTanggalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Status Pelaporan per Tanggal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onTabChange(0), // ke tab Riwayat admin
              child: const Text(
                'Lihat semua',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDaftarLaporanAdmin(context),
      ],
    );
  }

  Widget _buildDaftarLaporanAdmin(BuildContext context) {
    // Dummy data – nanti diganti Firestore
    final laporanList = [
      _AdminReport(
        judul: 'Kerusakan Proyektor Ruang 101',
        tanggal: '10 November 2025',
        status: 'Diajukan',
        color: const Color(0xFFD32F2F),
        icon: Icons.error_outline,
      ),
      _AdminReport(
        judul: 'Kursi Rusak di Lab Komputer',
        tanggal: '11 November 2025',
        status: 'Diproses',
        color: const Color(0xFFF57C00),
        icon: Icons.hourglass_top,
      ),
      _AdminReport(
        judul: 'Lampu Padam di Koridor',
        tanggal: '12 November 2025',
        status: 'Selesai',
        color: const Color(0xFF388E3C),
        icon: Icons.check_circle_outline,
      ),
    ];

    return Column(
      children: [
        for (final laporan in laporanList) ...[
          _buildReportCard(laporan),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildReportCard(_AdminReport laporan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Icon status
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: laporan.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(laporan.icon, color: laporan.color, size: 22),
          ),
          const SizedBox(width: 14),
          // Judul & tanggal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laporan.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  laporan.tanggal,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: laporan.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              laporan.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: laporan.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ MODEL CLASS KECIL ============

class _AdminReport {
  final String judul;
  final String tanggal;
  final String status;
  final Color color;
  final IconData icon;

  _AdminReport({
    required this.judul,
    required this.tanggal,
    required this.status,
    required this.color,
    required this.icon,
  });
}
