import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Kebijakan & Privasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              '1. Perolehan dan Pengumpulan Data Pribadi Pengguna Lapor JTI',
            ),
            _buildSectionContent(
              'Data Pribadi Pengguna Lapor JTI yang Kami kumpulkan adalah sebagai berikut:\n\n'
              '- Membuat atau memperbarui akun Lapor JTI.\n'
              '- Menghubungi Kami melalui fitur yang tersedia di dalam aplikasi.\n'
              '- Melakukan interaksi dengan Pengguna Lapor JTI lainnya melalui fitur yang terdapat dalam aplikasi.\n'
              '- Mengisi data-data yang diperlukan pada saat Pengguna Lapor JTI melakukan pengajuan laporan kerusakan fasilitas.\n\n'
              'Data yang terekam pada saat Pengguna Lapor JTI mempergunakan aplikasi antara lain:\n\n'
              '- Data lokasi saat mengajukan laporan kerusakan.\n'
              '- Data aktivitas Pengguna Lapor JTI dalam menggunakan aplikasi.\n'
              '- Data perangkat yang digunakan Pengguna Lapor JTI.\n\n'
              'Data yang diperoleh dari sumber lain, antara lain:\n\n'
              '- Data dari mitra usaha atau penyedia layanan terkait yang membantu Kami dalam mengembangkan dan menyajikan layanan-layanan dalam aplikasi Lapor JTI.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('2. Dasar Pemrosesan Data Pribadi'),
            _buildSectionContent(
              'Kami melakukan pemrosesan Data Pribadi Pengguna Lapor JTI berdasarkan:\n\n'
              '- Persetujuan yang sah dari Pengguna Lapor JTI untuk kepentingan marketing atau promosi pada layanan yang Kami berikan.\n'
              '- Pemenuhan kewajiban perjanjian terhadap Kebijakan Privasi ini (beserta Syarat & Ketentuan Lapor JTI).\n'
              '- Pelaksanaan kewenangan atau memenuhi kewajiban berdasarkan peraturan perundang-undangan/perintah instansi yang berwenang.\n'
              '- Pemenuhan kepentingan yang sah lainnya setelah dilakukan analisis dan penilaian terhadap tujuan dan keseimbangan kepentingan Pengguna Lapor JTI dan Kami.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('3. Tujuan Penggunaan Data Pribadi'),
            _buildSectionContent(
              'Kami akan melakukan pemrosesan Data Pribadi Pengguna Lapor JTI untuk tujuan sebagai berikut:\n\n'
              '- Identifikasi dan registrasi akun Pengguna Lapor JTI.\n'
              '- Melakukan verifikasi akun Pengguna Lapor JTI.\n'
              '- Memproses dan mengelola laporan kerusakan fasilitas.\n'
              '- Mencegah, mendeteksi, menyelidiki, dan mengatasi tindakan ilegal atau tidak sah yang terjadi dalam aplikasi.\n'
              '- Melakukan pemetaan demografis Pengguna Lapor JTI.\n'
              '- Memberikan notifikasi terkait status laporan dan informasi lainnya.\n'
              '- Berkomunikasi dengan Pengguna Lapor JTI sehubungan dengan layanan yang ada di aplikasi.\n'
              '- Melakukan survei dan analisis data untuk meningkatkan kualitas layanan Lapor JTI.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('4. Jenis Data Pribadi yang Dikumpulkan'),
            _buildSectionContent(
              'Kami mengumpulkan Data Pribadi sebagai berikut:\n\n'
              '- Data Pribadi Umum: Nama Lengkap, Email, Password.\n'
              '- Data Pribadi Spesifik: Foto, Data Lokasi, Data Laporan (termasuk kategori kerusakan, lokasi ruangan, deskripsi kerusakan).\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('5. Pelindungan Data Pribadi'),
            _buildSectionContent(
              'Penyimpanan Data Pribadi:\n\n'
              '- Kami melindungi Data Pribadi Pengguna Lapor JTI yang disimpan dalam sistem Lapor JTI, serta melindungi data tersebut dari akses yang tidak sah, pengubahan, pengungkapan, penyalahgunaan, atau penghancuran yang tidak sah dengan menggunakan prosedur keamanan yang memadai.\n\n'
              'Pengungkapan Data Pribadi:\n\n'
              '- Kami akan mengungkapkan Data Pribadi Pengguna Lapor JTI kepada:\n\n'
              '- Pihak yang menyediakan layanan yang tersedia di aplikasi Lapor JTI setelah mendapatkan persetujuan dari Pengguna.\n'
              '- Pihak ketiga untuk analisis data dan pemasaran untuk meningkatkan layanan aplikasi.\n'
              '- Aparat penegak hukum atau instansi pemerintah yang berwenang untuk melakukan pengawasan dan audit.\n\n'
              'Penghapusan Data Pribadi:\n\n'
              '- Data Pribadi Pengguna Lapor JTI akan dihapus apabila tidak lagi diperlukan untuk memenuhi tujuan dari pengumpulannya atau apabila Pengguna mengajukan permintaan penghapusan data pribadi sesuai prosedur yang berlaku.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(
              '6. Pelibatan Pihak Ketiga dalam Pemrosesan Data Pribadi',
            ),
            _buildSectionContent(
              'Dalam melakukan Pemrosesan Data Pribadi Anda, Kami melibatkan pihak ketiga sebagai Prosesor Data Pribadi yang tunduk pada Undang-Undang Perlindungan Data Pribadi. Kami memastikan bahwa pihak ketiga ini mengikuti standar perlindungan data yang berlaku.\n\n'
              '- Penyedia layanan hosting dan infrastruktur.\n'
              '- Penyedia layanan analitik dan monitoring.\n'
              '- Mitra pengiriman notifikasi dan email.\n'
              '- Penyedia layanan pihak ketiga lain yang mendukung operasional aplikasi.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('7. Penggunaan Teknologi Pelacakan'),
            _buildSectionContent(
              'Lapor JTI menggunakan teknologi pelacakan di perangkat Pengguna untuk menyimpan preferensi dan konfigurasi. Teknologi ini tidak digunakan untuk mengakses data pribadi lainnya di perangkat Pengguna, kecuali yang telah disetujui oleh Pengguna.\n\n'
              '- Cookies untuk menyimpan preferensi tampilan dan sesi.\n'
              '- Local storage untuk menyimpan konfigurasi aplikasi.\n'
              '- Layanan analitik untuk memahami penggunaan aplikasi dan meningkatkan layanan.\n'
              '- Teknologi pelacakan hanya digunakan sesuai persetujuan pengguna.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('8. Hak Pengguna Lapor JTI'),
            _buildSectionContent(
              'Pengguna Lapor JTI memiliki hak untuk:\n\n'
              '- Mengakses dan memperbarui data pribadi mereka.\n'
              '- Menghapus akun mereka dari aplikasi.\n'
              '- Mengajukan permohonan untuk menangguhkan atau menghentikan pemrosesan data pribadi mereka sesuai ketentuan yang berlaku.\n',
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('9. Perubahan pada Kebijakan Privasi'),
            _buildSectionContent(
              '- Kebijakan Privasi ini dapat diperbarui dari waktu ke waktu.\n'
              '- Setiap perubahan akan diinformasikan melalui aplikasi atau pemberitahuan resmi.\n'
              '- Pengguna disarankan untuk memeriksa Kebijakan Privasi secara berkala.\n',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    // Split into paragraphs by double newline
    final paragraphs = content
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(paragraphs.length, (index) {
          final para = paragraphs[index];
          final lines = para
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();

          // Detect if this paragraph is a bullet list (all lines start with '-')
          final isBulletList =
              lines.isNotEmpty && lines.every((l) => l.startsWith('-'));

          // Detect if next paragraph is a bullet list (so current is intro)
          final nextIsBullet =
              (index + 1 < paragraphs.length) &&
              paragraphs[index + 1]
                  .split('\n')
                  .map((l) => l.trim())
                  .any((l) => l.startsWith('-'));

          if (isBulletList) {
            // Render bullets with indent
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines.map<Widget>((line) {
                final text = line.replaceFirst(RegExp(r'^\-\s*'), '');
                return Padding(
                  padding: const EdgeInsets.only(left: 18.0, bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }

          // If this paragraph is an intro followed by bullets, indent the intro slightly
          if (nextIsBullet) {
            final paragraphText = lines.join(' ');
            return Padding(
              padding: const EdgeInsets.only(left: 18.0, bottom: 6.0),
              child: Text(
                paragraphText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            );
          }

          // If paragraph starts with a single '-' line then subsequent lines treated as bullets
          if (lines.isNotEmpty && lines.first.startsWith('-')) {
            final firstLine = lines.first.replaceFirst(RegExp(r'^\-\s*'), '');
            final remaining = lines.sublist(1);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    firstLine,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                if (remaining.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: remaining.map<Widget>((line) {
                      final text = line.replaceFirst(RegExp(r'^\-\s*'), '');
                      return Padding(
                        padding: const EdgeInsets.only(left: 18.0, bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            );
          }

          // Normal paragraph
          final paragraphText = lines.join(' ');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              paragraphText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          );
        }),
      ),
    );
  }
}
// ...existing code...