import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pelaporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Laporan 1'),
            subtitle: Text('Status: Diajukan'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Laporan 2'),
            subtitle: Text('Status: Diproses'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
