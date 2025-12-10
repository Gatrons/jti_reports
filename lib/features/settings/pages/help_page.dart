import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Bantuan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildFAQItem(
            context,
            "Bagaimana cara membuat laporan kerusakan fasilitas?",
            "Pengguna dapat membuat laporan dengan memilih kategori kerusakan, lokasi ruangan, dan mengisi deskripsi kerusakan. Foto pendukung juga bisa diunggah untuk memperjelas kondisi kerusakan.",
          ),
          _buildFAQItem(
            context,
            "Apa yang harus dilakukan jika tidak bisa login ke aplikasi?",
            "Pastikan Anda menggunakan email dan password yang benar, serta email yang digunakan telah diverifikasi. Jika masih mengalami masalah, coba lakukan reset password melalui fitur 'Lupa Password'.",
          ),
          _buildFAQItem(
            context,
            "Bagaimana cara melihat riwayat laporan saya?",
            "Anda dapat mengakses riwayat laporan dengan membuka halaman 'Riwayat Laporan' di aplikasi. Di sana, Anda bisa melihat status laporan sebelumnya dan informasi lainnya.",
          ),
          _buildFAQItem(
            context,
            "Bagaimana cara mengubah status laporan?",
            "Hanya admin yang memiliki hak untuk mengubah status laporan. Anda sebagai pelapor hanya dapat melihat status laporan yang telah diperbarui oleh admin.",
          ),
          _buildFAQItem(
            context,
            "Bagaimana jika saya ingin melaporkan kerusakan yang terjadi di luar gedung JTI?",
            "Aplikasi ini hanya mencakup pelaporan kerusakan fasilitas di dalam gedung Jurusan Teknologi Informasi. Kerusakan di luar gedung tidak dapat dilaporkan melalui aplikasi ini.",
          ),
          _buildFAQItem(
            context,
            "Bisakah saya melaporkan kerusakan tanpa foto?",
            "Ya, meskipun foto pendukung sangat dianjurkan untuk memperjelas kondisi kerusakan, Anda masih bisa membuat laporan tanpa menyertakan foto.",
          ),
          _buildFAQItem(
            context,
            "Apakah aplikasi ini dapat digunakan oleh pihak selain mahasiswa dan dosen?",
            "Saat ini, aplikasi hanya tersedia untuk mahasiswa, dosen, dan staf Jurusan Teknologi Informasi Politeknik Negeri Malang.",
          ),
          _buildFAQItem(
            context,
            "Bagaimana cara logout dari aplikasi?",
            "Anda dapat logout dengan menekan tombol 'Logout' yang ada di menu pengaturan akun.",
          ),
        ],
      ),
      backgroundColor: Colors.indigo[50],
    );
  }

    Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  answer,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
