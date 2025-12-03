import 'package:flutter/material.dart';
// import 'package:jti_reports/features/riwayat/pages/detail_laporan_page.dart';
// import 'package:jti_reports/features/riwayat/pages/riwayat_page.dart';
// import 'package:jti_reports/features/lapor/pages/tambah_laporan_page.dart';

import '../../../core/widgets/appbar/main_app_bar.dart';
import '../../../core/widgets/drawer/main_drawer.dart';
import 'package:jti_reports/core/widgets/reports/reports_list.dart';

class HomePage extends StatelessWidget {
  final void Function(int index) onTabChange;

  const HomePage({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const MainAppBar(title: 'Beranda'),
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
          _buildBuatLaporanCard(),
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

  Widget _buildBuatLaporanCard() {
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

          ElevatedButton(
            onPressed: () => onTabChange(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Buat Laporan',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),

          const SizedBox(height: 5),

          // ⬇⬇ FIX: pindah ke tab "Riwayat"
          TextButton(
            onPressed: () => onTabChange(0),
            child: Text(
              'Lihat Riwayat Pelaporan',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTombolBuatLaporan(BuildContext context) {
  //   return ElevatedButton(
  //     onPressed: () => _navigateToTambahLaporan(context),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.deepPurple,
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     ),
  //     child: const Text(
  //       'Buat Laporan',
  //       style: TextStyle(fontSize: 16, color: Colors.white),
  //     ),
  //   );
  // }

  // Widget _buildTombolLihatRiwayat(BuildContext context) {
  //   return TextButton(
  //     onPressed: () => _navigateToRiwayat(context),
  //     child: Text(
  //       'Lihat Riwayat Pelaporan',
  //       style: TextStyle(color: Colors.deepPurple),
  //     ),
  //   );
  // }

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
    return ReportsList(
      clientSort: true,
      onCardTap: (doc) {
        navigateToDetailLaporan(context, doc);
      },
    );
  }

  // Widget _buildBadgeStatus(LaporanModel laporan) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: laporan.warnaStatus.withOpacity(0.2),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Text(
  //       laporan.status,
  //       style: TextStyle(
  //         color: laporan.warnaStatus,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }

  // ============ METHOD NAVIGASI ============
  // void _navigateToTambahLaporan(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const TambahlaporanPage()),
  //   );
  // }

  // void _navigateToRiwayat(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const RiwayatPage()),
  //   );
  // }
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
