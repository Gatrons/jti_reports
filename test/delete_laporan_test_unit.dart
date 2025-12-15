import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// GANTI sesuai path kamu
import 'package:jti_reports/features/riwayat/pages/detail_laporan_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete laporan -> dialog muncul -> print data terdelete', (
    tester,
  ) async {
    // ===== Data sample (sesuai yang kamu kasih) =====
    const docId = '2MW99WlBEznD1fPUZ1AA';
    const deskripsi = 'kursi terbelah 2';
    const jenisKerusakan = 'kursi potek';
    const lokasi = 'lkj1-lt7b';
    const status = 'Diajukan';
    const tingkatKeparahan = 'Bahaya';
    const timestampStr = 'December 6, 2025 at 8:36:46 PM UTC+7';

    // PENTING: kosongkan supaya kode kamu tidak mencoba delete ke Supabase
    // (karena kamu pakai Supabase.instance.client di page, dan itu sulit dimock tanpa ubah page)
    const mediaPaths = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: DetailLaporanPage(
          title: jenisKerusakan,
          date: timestampStr,
          status: status,
          statusColor: Colors.orange,
          deskripsi: deskripsi,
          keparahan: tingkatKeparahan,
          lokasi: lokasi,
          docId: docId,
          mediaPaths: mediaPaths,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll sampai tombol Delete terlihat
    final deleteText = find.text('Delete');
    await tester.scrollUntilVisible(
      deleteText,
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(deleteText, findsOneWidget);

    // Tap Delete => muncul dialog
    await tester.tap(deleteText);
    await tester.pumpAndSettle();

    expect(find.text('Hapus Laporan'), findsOneWidget);

    // Tap Hapus => jalankan _deleteReport
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // ==========================
    // PRINT DATA YANG TERDELETE
    // ==========================
    debugPrint('=== DATA LAPORAN TERDELETE ===');
    debugPrint('Document ID       : $docId');
    debugPrint('deskripsi         : $deskripsi');
    debugPrint('jenis_kerusakan   : $jenisKerusakan');
    debugPrint('lokasi            : $lokasi');
    debugPrint('media_paths       : $mediaPaths');
    debugPrint('status            : $status');
    debugPrint('timestamp         : $timestampStr');
    debugPrint('tingkat_keparahan : $tingkatKeparahan');
    debugPrint('================================');

    // NOTE:
    // Karena kamu tidak mau ubah DetailLaporanPage, dan firebase/supabase belum tentu
    // ke-init di test, maka yang bisa dipastikan di widget/unit test ini adalah:
    // - UI flow delete & dialog jalan
    // - data yang diminta untuk dihapus berhasil diprint
    //
    // Kalau kamu mau sekalian memastikan benar-benar memanggil Firestore delete,
    // itu butuh mock Firebase initialize + mock channel firestore (pigeon/methodchannel)
    // yang sesuai versi plugin kamu.
  });
}
