import 'package:flutter/material.dart';

class OnboardingConstants {
  // Teks
  static const String teksLewati = 'Lewati';
  static const String teksTombolLanjut = 'Lanjut';
  static const String teksTombolMulai = 'Mulai Lapor';

  // Warna
  static const Color warnaDeepPurple = Color(0xFF67008C);
  static const Color warnaDarkPurple = Color(0xFF1C0026);

  // Gradient
  static const List<Color> gradientWarna = [
    warnaDeepPurple,
    Colors.purpleAccent,
    warnaDarkPurple,
  ];

  // Durasi
  static const Duration durasiAnimasi = Duration(milliseconds: 600);
  static const Duration durasiTransisiHalaman = Duration(milliseconds: 400);
  static const Duration durasiAnimasiIndikator = Duration(milliseconds: 200);

  // Data Halaman Onboarding
  static const List<OnboardingData> dataHalaman = [
    OnboardingData(
      judul: 'Lapor Fasilitas Rusak',
      deskripsi:
          'Laporkan fasilitas yang rusak, kotor, atau tidak layak pakai di lingkungan JTI. '
          'Isi detail laporan, pilih lokasi, dan unggah foto agar bisa segera ditindaklanjuti.',
      emoji: '🛠️',
    ),
    OnboardingData(
      judul: 'Pantau Progres Laporan',
      deskripsi:
          'Pantau status laporanmu mulai dari diajukan, diproses, hingga selesai. '
          'Riwayat laporan tersimpan rapi sehingga kamu tahu sejauh mana tindak lanjutnya.',
      emoji: '📊',
    ),
    OnboardingData(
      judul: 'Bersama Jaga Kampus Nyaman',
      deskripsi:
          'Setiap laporan yang kamu kirim membantu menjaga JTI tetap aman dan nyaman untuk belajar. '
          'Mari berkolaborasi menjaga fasilitas kampus.',
      emoji: '🤝',
    ),
  ];
}

class OnboardingData {
  final String judul;
  final String deskripsi;
  final String emoji;

  const OnboardingData({
    required this.judul,
    required this.deskripsi,
    required this.emoji,
  });
}
