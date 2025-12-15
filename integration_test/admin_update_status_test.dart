import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jti_reports/core/widgets/loading_button.dart';
import 'package:jti_reports/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'Test Update Status Laporan',
    () {
      testWidgets(
        '[A] Berhasil update laporan',
        (tester) async {
          print("Mulai Test A - Update Status Laporan");
          app.main();
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(TextButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(0), 'atherosmurf@gmail.com');
          await Future.delayed(const Duration(seconds: 2));
          await tester.enterText(find.byType(TextFormField).at(1), 'adminsaja');
          await Future.delayed(const Duration(seconds: 2));
          await tester.tap(find.byType(LoadingButton).at(0));
          await Future.delayed(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));

          await tester.tap(find.byIcon(Icons.history).first);
          await tester.pumpAndSettle();
          await Future.delayed(const Duration(seconds: 2));

          await tester.tap(find.byType(DropdownButton<String>).at(3));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Diproses').last);
          await Future.delayed(const Duration(seconds: 2));
          
          expect(find.text('Status diubah: Diproses'), findsOneWidget);
          print("Test A Selesai");
        },
      );
    },
  );
}
