import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      //abaikan error
    }
  });

  group('register test', () {
    testWidgets('[A] Berhasil', (tester) async {
      print("Mulai Test A - Input Valid");
      app.main();
      await tester.pumpAndSettle();

      final lewatiButton = find.text('Lewati');
      if (tester.any(lewatiButton)) {
        await tester.tap(lewatiButton);
        await tester.pumpAndSettle();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final daftarFooter = find.widgetWithText(GestureDetector, 'Daftar');
      await tester.ensureVisible(daftarFooter);
      await tester.tap(daftarFooter);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'testuser22@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'Password123');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 300));

      final checkboxFinder = find.byType(AnimatedContainer).first;
      await tester.ensureVisible(checkboxFinder);
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      final buatAkunButton = find.widgetWithText(LoadingButton, 'Buat Akun');
      await tester.ensureVisible(buatAkunButton);
      await tester.tap(buatAkunButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Verifikasi Email Anda'), findsOneWidget);
    });

    testWidgets('[B] Gagal', (tester) async {
      print("Mulai Test B - Tanpa Menyetujui Kebijakan");
      app.main();
      await tester.pumpAndSettle();

      final lanjutButton = find.text('Lanjut');
      final mulaiButton = find.text('Mulai Lapor');

      for (int i = 0; i < 2; i++) {
        if (tester.any(lanjutButton)) {
          await tester.tap(lanjutButton);
          await tester.pumpAndSettle();
        }
      }

      if (tester.any(mulaiButton)) {
        await tester.tap(mulaiButton);
        await tester.pumpAndSettle();
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final daftarFooter = find.widgetWithText(GestureDetector, 'Daftar');
      await tester.ensureVisible(daftarFooter);
      await tester.tap(daftarFooter);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'testuser21@gmail.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'Password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'Password123');
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 300));

      final buatAkunButton = find.widgetWithText(LoadingButton, 'Buat Akun');
      await tester.ensureVisible(buatAkunButton);
      await tester.tap(buatAkunButton);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.byType(SnackBar), findsOneWidget);

      expect(
        find.text('Anda harus menyetujui syarat & ketentuan'),
        findsWidgets,
      );
    });
  });
}
