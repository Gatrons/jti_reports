import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jti_reports/features/settings/pages/change_password_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChangePasswordPage()));
    await tester.pumpAndSettle();
  }

  Future<void> enterOld(WidgetTester tester, String v) async {
    await tester.enterText(find.byType(TextFormField).at(0), v);
    await tester.pump();
  }

  Future<void> enterNew(WidgetTester tester, String v) async {
    await tester.enterText(find.byType(TextFormField).at(1), v);
    await tester.pump();
  }

  Future<void> enterConfirm(WidgetTester tester, String v) async {
    await tester.enterText(find.byType(TextFormField).at(2), v);
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester) async {
    // LoadingButton internal biasanya pakai ElevatedButton/TextButton.
    // Yang paling stabil: tap berdasarkan teks.
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();
  }

  group('Change Password - unit/widget test validasi per field', () {
    testWidgets(
      'Old password kosong -> muncul error "Password lama tidak boleh kosong"',
      (tester) async {
        await pumpPage(tester);

        // Isi yang lain valid supaya error fokus ke old password
        await enterNew(tester, '123456'); // minimal 6 karakter
        await enterConfirm(tester, '123456');

        await tapSave(tester);

        expect(find.text('Password lama tidak boleh kosong'), findsOneWidget);
      },
    );

    testWidgets(
      'New password < 6 -> muncul error dari Validators.validasiPassword',
      (tester) async {
        await pumpPage(tester);

        await enterOld(tester, 'oldpass');
        await enterNew(tester, '123'); // invalid
        await enterConfirm(tester, '123');

        await tapSave(tester);

        expect(find.text('Password minimal 6 karakter'), findsOneWidget);
      },
    );

    testWidgets(
      'New password > 20 -> muncul error "Password maksimal 20 karakter"',
      (tester) async {
        await pumpPage(tester);

        await enterOld(tester, 'oldpass');
        await enterNew(tester, '123456789012345678901'); // 21 char
        await enterConfirm(tester, '123456789012345678901');

        await tapSave(tester);

        expect(find.text('Password maksimal 20 karakter'), findsOneWidget);
      },
    );

    testWidgets(
      'Confirm tidak sama -> muncul error "Konfirmasi password tidak sesuai"',
      (tester) async {
        await pumpPage(tester);

        await enterOld(tester, 'oldpass');
        await enterNew(tester, '123456');
        await enterConfirm(tester, '654321');

        await tapSave(tester);

        expect(find.text('Konfirmasi password tidak sesuai'), findsOneWidget);
      },
    );
  });
}
