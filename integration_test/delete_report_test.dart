import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder inputFields() => find.byType(EditableText);

  Future<void> shortDelay() async => Future.delayed(const Duration(seconds: 1));
  Future<void> normalDelay() async =>
      Future.delayed(const Duration(seconds: 2));

  bool isOnHome() {
    return find.byIcon(Icons.history).evaluate().isNotEmpty ||
        find.byIcon(Icons.add_circle_outline).evaluate().isNotEmpty ||
        find.byIcon(Icons.home).evaluate().isNotEmpty ||
        find.byType(BottomNavigationBar).evaluate().isNotEmpty;
  }

  Future<void> hideKeyboard(WidgetTester tester) async {
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await shortDelay();
  }

  Future<void> doLogin(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await normalDelay();

    if (isOnHome()) return;

    if (find.text('Lewati').evaluate().isNotEmpty) {
      await tester.tap(find.text('Lewati').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await normalDelay();
    }

    if (isOnHome()) return;

    expect(
      inputFields().evaluate().length >= 2,
      true,
      reason: 'Field login tidak ditemukan setelah klik Lewati',
    );

    await tester.tap(inputFields().at(0));
    await tester.enterText(inputFields().at(0), 'afriansyy@gmail.com');
    await tester.pumpAndSettle();
    await shortDelay();

    await tester.tap(inputFields().at(1));
    await tester.enterText(inputFields().at(1), 'Afriansyah12');
    await tester.pumpAndSettle();
    await shortDelay();

    await hideKeyboard(tester);

    final loginBtn = find.byType(LoadingButton);
    expect(loginBtn.evaluate().isNotEmpty, true);

    await tester.tap(loginBtn.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    bool loggedIn = false;
    for (int i = 0; i < 20; i++) {
      await tester.pumpAndSettle();
      await shortDelay();
      if (isOnHome()) {
        loggedIn = true;
        break;
      }
    }

    expect(loggedIn, true, reason: 'Login gagal (marker home tidak muncul)');
  }

  Future<void> openRiwayat(WidgetTester tester) async {
    if (find.byIcon(Icons.history).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.history).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await normalDelay();
      return;
    }

    fail('Tidak menemukan tombol/icon menuju Riwayat (Icons.history).');
  }

  Future<void> openDetailByTitle(WidgetTester tester, String title) async {
    final scrollable = find.byType(Scrollable);
    expect(scrollable.evaluate().isNotEmpty, true);

    final target = find.textContaining(title);

    for (int i = 0; i < 15; i++) {
      if (target.evaluate().isNotEmpty) {
        await tester.tap(target.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        await normalDelay();
        return;
      }
      await tester.fling(scrollable.first, const Offset(0, -900), 1200);
      await tester.pumpAndSettle();
      await shortDelay();
    }

    fail('Laporan "$title" tidak ditemukan di riwayat');
  }

  Future<void> scrollToBottom(WidgetTester tester) async {
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.fling(scrollable.first, const Offset(0, -1200), 1200);
      await tester.pumpAndSettle();
      await shortDelay();
    }
  }

  Future<void> tapDelete(WidgetTester tester) async {
    if (find.text('Delete').evaluate().isNotEmpty) {
      await tester.tap(find.text('Delete').first, warnIfMissed: false);
    } else if (find.byIcon(Icons.delete).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.delete).first, warnIfMissed: false);
    } else {
      fail('Tombol Delete tidak ditemukan');
    }
    await tester.pumpAndSettle();
    await shortDelay();
  }

  group('Test Hapus Laporan', () {
    testWidgets('[A] Berhasil hapus laporan', (tester) async {
      await doLogin(tester);
      await openRiwayat(tester);
      await openDetailByTitle(tester, 'Integration Testing - Updated');

      await scrollToBottom(tester);
      await tapDelete(tester);

      expect(find.text('Hapus Laporan'), findsOneWidget);
      await tester.tap(find.text('Hapus').last, warnIfMissed: false);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      expect(find.text('Laporan berhasil dihapus'), findsOneWidget);
    });
  });
}
