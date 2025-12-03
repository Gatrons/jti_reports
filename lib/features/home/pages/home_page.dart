import 'package:flutter/material.dart';
import 'package:jti_reports/pages/detail_laporan_page.dart';
import 'package:jti_reports/pages/riwayat_page.dart';
import 'package:jti_reports/pages/tambah_laporan_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody(context));
  }

  // ============ METHOD BUILD WIDGET ============
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Beranda',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.deepPurple,
      elevation: 4,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildHeaderWelcome(),
          const SizedBox(height: 20),
          _buildBuatLaporanCard(context),
          const SizedBox(height: 30),
          _buildLaporanTerakhirSection(context),
        ],
      ),
    );
  }

  Widget _buildHeaderWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Laporkan kerusakan fasilitas kampus dengan cepat.',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildBuatLaporanCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Icon(Icons.assignment, color: Colors.deepPurple, size: 40),
          const SizedBox(height: 10),
          Text(
            'Ingin melaporkan kerusakan?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          _buildTombolBuatLaporan(context),
          const SizedBox(height: 5),
          _buildTombolLihatRiwayat(context),
        ],
      ),
    );
  }

  Widget _buildTombolBuatLaporan(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToTambahLaporan(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text(
        'Buat Laporan',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildTombolLihatRiwayat(BuildContext context) {
    return TextButton(
      onPressed: () => _navigateToRiwayat(context),
      child: Text(
        'Lihat Riwayat Pelaporan',
        style: TextStyle(color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildLaporanTerakhirSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Laporan Terakhir Anda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 10),
        _buildDaftarLaporan(context),
      ],
    );
  }

  Widget _buildDaftarLaporan(BuildContext context) {
    final List<LaporanModel> daftarLaporan = [
      LaporanModel(
        judul: "Kerusakan Toilet",
        tanggal: "10 November 2025",
        status: "Diajukan",
        warnaStatus: Colors.redAccent,
        ikon: Icons.report,
      ),
      LaporanModel(
        judul: "Lampu Mati",
        tanggal: "12 November 2025",
        status: "Diproses",
        warnaStatus: Colors.orangeAccent,
        ikon: Icons.report,
      ),
      LaporanModel(
        judul: "AC Tidak Dingin",
        tanggal: "14 November 2025",
        status: "Selesai",
        warnaStatus: Colors.green,
        ikon: Icons.report,
      ),
    ];

    return Column(
      children: daftarLaporan
          .map((laporan) => _buildCardLaporan(context, laporan))
          .toList(),
    );
  }

  Widget _buildCardLaporan(BuildContext context, LaporanModel laporan) {
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
        onTap: () => _navigateToDetailLaporan(context, laporan),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: laporan.warnaStatus.withOpacity(0.2),
          child: Icon(laporan.ikon, color: laporan.warnaStatus, size: 28),
        ),
        title: Text(
          laporan.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(laporan.tanggal),
        trailing: _buildBadgeStatus(laporan),
      ),
    );
  }

  Widget _buildBadgeStatus(LaporanModel laporan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: laporan.warnaStatus.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        laporan.status,
        style: TextStyle(
          color: laporan.warnaStatus,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============ METHOD NAVIGASI ============
  void _navigateToTambahLaporan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahlaporanPage()),
    );
  }

  void _navigateToRiwayat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RiwayatPage()),
    );
  }

  void _navigateToDetailLaporan(BuildContext context, LaporanModel laporan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailLaporanPage(
          title: laporan.judul,
          date: laporan.tanggal,
          status: laporan.status,
          statusColor: laporan.warnaStatus,
        ),
      ),
    );
  }
}

// ============ MODEL CLASS ============
class LaporanModel {
  final String judul;
  final String tanggal;
  final String status;
  final Color warnaStatus;
  final IconData ikon;

  const LaporanModel({
    required this.judul,
    required this.tanggal,
    required this.status,
    required this.warnaStatus,
    required this.ikon,
  });
}
