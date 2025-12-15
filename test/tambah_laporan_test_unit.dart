import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jti_reports/features/lapor/pages/tambah_laporan_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TambahlaporanPage(onTabChange: (_) {})),
    );
    await tester.pumpAndSettle();
  }

  Finder submitText() => find.text('Kirim Laporan');
  Finder scrollable() => find.byType(Scrollable); // SingleChildScrollView

  Future<void> scrollToSubmit(WidgetTester tester) async {
    // drag sampai text "Kirim Laporan" terlihat
    await tester.dragUntilVisible(
      submitText(),
      scrollable(),
      const Offset(0, -300), // drag ke atas = scroll ke bawah
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await scrollToSubmit(tester);

    // Tap ke ElevatedButton yang membungkus text tersebut
    final btn = find.ancestor(
      of: submitText(),
      matching: find.byType(ElevatedButton),
    );

    // kalau ternyata ada lebih dari 1, ambil yang pertama
    await tester.tap(btn.first);
    await tester.pump(); // mulai animasi snackbar
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> fillJenis(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).at(0), text);
    await tester.pump();
  }

  Future<void> fillLokasi(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).at(1), text);
    await tester.pump();
  }

  Future<void> fillDeskripsi(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField).at(2), text);
    await tester.pump();
  }

  group('Tambah Laporan - Validasi per Field', () {
    testWidgets('Jenis kerusakan kosong', (tester) async {
      await pumpPage(tester);
      await tapSubmit(tester);
      expect(find.text('Jenis kerusakan harus diisi'), findsOneWidget);
    });

    testWidgets('Lokasi kosong', (tester) async {
      await pumpPage(tester);
      await fillJenis(tester, 'AC Mati');
      await tapSubmit(tester);
      expect(find.text('Lokasi fasilitas harus diisi'), findsOneWidget);
    });

    testWidgets('Deskripsi kosong', (tester) async {
      await pumpPage(tester);
      await fillJenis(tester, 'AC Mati');
      await fillLokasi(tester, 'LPR1-LT7B');
      await tapSubmit(tester);
      expect(find.text('Deskripsi kerusakan harus diisi'), findsOneWidget);
    });

    testWidgets('Severity belum dipilih', (tester) async {
      await pumpPage(tester);
      await fillJenis(tester, 'AC Mati');
      await fillLokasi(tester, 'LPR1-LT7B');
      await fillDeskripsi(tester, 'AC tidak menyala');
      await tapSubmit(tester);
      expect(find.text('Tingkat keparahan harus dipilih'), findsOneWidget);
    });
  });
}
