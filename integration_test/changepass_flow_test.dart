import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
  });

  group('Tes Ganti Sandi', () {
    testWidgets('[A] Berhasil', (tester) async {
      print("Mulai Test A - Input Valid");
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 800));

      // LEWATI ONBOARDING
      final lewatiButton = find.text('Lewati');
      if (tester.any(lewatiButton)) {
        await tester.tap(lewatiButton);
        await tester.pumpAndSettle();
      }

      // TUNGGU LOGIN
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        while (find.byType(TextFormField).evaluate().length < 2) {
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        }
      });

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'rohmanalka06@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'alkabaru');
      await tester.pumpAndSettle();

      final loginButton =
          tester.any(find.widgetWithText(ElevatedButton, 'Masuk'))
          ? find.widgetWithText(ElevatedButton, 'Masuk')
          : find.widgetWithText(LoadingButton, 'Masuk');

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));

      // OPEN DRAWER
      final drawerBtn = find.byTooltip('Open navigation menu');
      if (tester.any(drawerBtn)) {
        await tester.tap(drawerBtn);
      } else {
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
      }
      await tester.pumpAndSettle();

      // MENU PENGATURAN
      final pengaturan = find.widgetWithText(ListTile, 'Pengaturan');
      await tester.ensureVisible(pengaturan);
      await tester.tap(pengaturan);
      await tester.pumpAndSettle();

      // GANTI SANDI
      final gantiSandi = find.text('Ganti Sandi');
      if (!tester.any(gantiSandi)) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      }
      await tester.ensureVisible(gantiSandi);
      await tester.tap(gantiSandi);
      await tester.pumpAndSettle();

      // ISI FORM
      await tester.enterText(find.byType(TextFormField).at(0), 'alkabaru');
      await tester.enterText(find.byType(TextFormField).at(1), 'alkabaru1');
      await tester.enterText(find.byType(TextFormField).at(2), 'alkabaru1');
      await tester.pumpAndSettle();

      // SIMPAN
      final simpan = find.widgetWithText(LoadingButton, 'Simpan Perubahan');
      await tester.tap(simpan);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      // VALIDASI
      expect(find.text('Password berhasil diperbarui!'), findsOneWidget);
      print("Test A Selesai");
    });

    testWidgets('[B] Gagal', (tester) async {
      print('Mulai Test B - Password Lama Salah');
      app.main();
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 800));

      // LEWATI ONBOARDING
      final lewatiButton = find.text('Lewati');
      if (tester.any(lewatiButton)) {
        await tester.tap(lewatiButton);
        await tester.pumpAndSettle();
      }

      // TUNGGU LOGIN
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        while (find.byType(TextFormField).evaluate().length < 2) {
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        }
      });

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'rohmanalka06@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'alkabaru1');
      await tester.pumpAndSettle();

      final loginButton =
          tester.any(find.widgetWithText(ElevatedButton, 'Masuk'))
          ? find.widgetWithText(ElevatedButton, 'Masuk')
          : find.widgetWithText(LoadingButton, 'Masuk');

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 5));

      // OPEN DRAWER
      final drawerBtn = find.byTooltip('Open navigation menu');
      if (tester.any(drawerBtn)) {
        await tester.tap(drawerBtn);
      } else {
        await tester.dragFrom(const Offset(0, 300), const Offset(300, 0));
      }
      await tester.pumpAndSettle();

      // PENGATURAN
      final pengaturan = find.widgetWithText(ListTile, 'Pengaturan');
      await tester.ensureVisible(pengaturan);
      await tester.tap(pengaturan);
      await tester.pumpAndSettle();

      // GANTI SANDI
      final gantiSandi = find.text('Ganti Sandi');
      if (!tester.any(gantiSandi)) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      }
      await tester.ensureVisible(gantiSandi);
      await tester.tap(gantiSandi);
      await tester.pumpAndSettle();

      // FORM SALAH
      await tester.enterText(find.byType(TextFormField).at(0), 'passbeda');
      await tester.enterText(find.byType(TextFormField).at(1), 'alkautsar');
      await tester.enterText(find.byType(TextFormField).at(2), 'alkautsar');
      await tester.pumpAndSettle();

      final simpan = find.widgetWithText(LoadingButton, 'Simpan Perubahan');
      await tester.ensureVisible(simpan);
      await tester.tap(simpan);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.text('Password lama salah'), findsOneWidget);
      print('Test B Selesai');
    });
  });
}
