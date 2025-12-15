import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jti_reports/features/lapor/pages/update_laporan_page.dart';

void main() {
  // Finder yang stabil
  Finder submitText() => find.text('Simpan Perubahan');
  Finder scrollable() => find.byType(Scrollable); // SingleChildScrollView

  Future<void> pumpPage(
    WidgetTester tester, {
    required String initialJenis,
    required String initialLokasi,
    required String initialDeskripsi,
    required String? initialSeverity,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UpdateLaporanPage(
          docId: '2MW99WlBEznD1fPUZ1AA',
          initialJenis: initialJenis,
          initialLokasi: initialLokasi,
          initialDeskripsi: initialDeskripsi,
          initialSeverity: initialSeverity,
          initialMediaPaths: const [],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToSubmit(WidgetTester tester) async {
    await tester.dragUntilVisible(
      submitText(),
      scrollable(),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    await scrollToSubmit(tester);

    final btn = find.ancestor(
      of: submitText(),
      matching: find.byType(ElevatedButton),
    );

    await tester.tap(btn.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // Urutan TextField di UpdateLaporanPage:
  // 0 = jenis, 1 = lokasi, 2 = deskripsi
  Future<void> setJenis(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).at(0), value);
    await tester.pump();
  }

  Future<void> setLokasi(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).at(1), value);
    await tester.pump();
  }

  Future<void> setDeskripsi(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextField).at(2), value);
    await tester.pump();
  }

  group('Update Laporan - Validasi per Field', () {
    testWidgets('Jenis kerusakan kosong -> SnackBar', (tester) async {
      // initial diset valid semua dulu supaya kita bisa kontrol via enterText
      await pumpPage(
        tester,
        initialJenis: 'AC Mati Unit Test',
        initialLokasi: 'LPR1-LT7B Unit Test',
        initialDeskripsi: 'desc Unit Test',
        initialSeverity: 'Rendah',
      );

      await setJenis(tester, '');
      await tapSubmit(tester);

      expect(find.text('Jenis kerusakan harus diisi'), findsOneWidget);
    });

    testWidgets('Lokasi kosong -> SnackBar', (tester) async {
      await pumpPage(
        tester,
        initialJenis: 'AC Mati Unit Test 2',
        initialLokasi: 'LPR1-LT7B',
        initialDeskripsi: 'desc',
        initialSeverity: 'Rendah',
      );

      await setLokasi(tester, '');
      await tapSubmit(tester);

      expect(find.text('Lokasi fasilitas harus diisi'), findsOneWidget);
    });

    testWidgets('Deskripsi kosong -> SnackBar', (tester) async {
      await pumpPage(
        tester,
        initialJenis: 'AC Mati Unit Test 3',
        initialLokasi: 'LPR1-LT7B',
        initialDeskripsi: 'desc',
        initialSeverity: 'Rendah',
      );

      await setDeskripsi(tester, '');
      await tapSubmit(tester);

      expect(find.text('Deskripsi kerusakan harus diisi'), findsOneWidget);
    });

    testWidgets('Severity null -> SnackBar "Tingkat keparahan harus dipilih"', (
      tester,
    ) async {
      // Severity sengaja null supaya kena validasi severity
      await pumpPage(
        tester,
        initialJenis: 'AC Mati Unit Test 4',
        initialLokasi: 'LPR1-LT7B',
        initialDeskripsi: 'desc',
        initialSeverity: null,
      );

      // pastikan field lain tetap valid
      await tapSubmit(tester);

      expect(find.text('Tingkat keparahan harus dipilih'), findsOneWidget);
    });
  });
}
