import 'package:flutter/material.dart';
import '../../../core/widgets/appbar/main_app_bar.dart';
import '../../../core/widgets/drawer/main_drawer.dart';
import 'package:jti_reports/core/widgets/reports/reports_list.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key, required void Function(int index) onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const MainAppBar(title: 'Riwayat'),
      backgroundColor: Colors.indigo[50],
      body: _buildBody(context),
    );
  }

  // ============ METHOD BUILD WIDGET ============
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(children: [_buildDaftarLaporan(context)]),
    );
  }

  Widget _buildDaftarLaporan(BuildContext context) {
    return ReportsList(
      clientSort: true,
      onCardTap: (doc) {
        navigateToDetailLaporan(context, doc);
      },
    );
  }
}
