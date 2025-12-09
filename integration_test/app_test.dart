import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/main.dart' as app;
import 'package:jti_reports/features/home/pages/home_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'login test',
    () {
      testWidgets(
        'verify login screen with correct username and password',
        (tester) async {
          app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(TextButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(0), 'afriansyy@gmail.com');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(1), 'Afriansyah12');
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(LoadingButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.pumpAndSettle();

          await Future.delayed(const Duration(seconds: 2));
          expect(find.byType(HomePage), findsOneWidget);
        },
      );

      testWidgets(
        'verify login screen with incorrect username and password',
        (tester) async {
          app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(TextButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(0), 'wrongemail@gmail.com');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(1), 'incorrectpassword');
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(LoadingButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.pumpAndSettle();

          await Future.delayed(const Duration(seconds: 2));
          expect(find.text('The supplied auth credential is incorrect, malformed or has expired.'), findsOneWidget);
        },
      );
    },
  );

  group(
    'tambah laporan test',
    () {
      testWidgets(
        'verify form tambah laporan with valid data',
        (tester) async {
          app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(TextButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(0), 'afriansyy@gmail.com');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(1), 'Afriansyah12');
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(LoadingButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));

          await tester.tap(find.byIcon(Icons.add_circle_outline).first);
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextField).at(0), 'Integration Testing');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextField).at(1), 'LKJ3-LT7B');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextField).at(2), 'Ini adalah laporan dari integration testing.');
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(DropdownButton<String>).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Rendah').last);
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(ElevatedButton));
          await Future.delayed(const Duration(seconds: 2));
          await tester.pumpAndSettle();

          await Future.delayed(const Duration(seconds: 2));
          expect(find.text('Laporan berhasil dikirim'), findsOneWidget);
        },
      );
    },
  );
}