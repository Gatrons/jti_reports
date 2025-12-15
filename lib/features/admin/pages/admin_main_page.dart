import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:jti_reports/features/admin/pages/admin_page.dart';
import 'package:jti_reports/features/admin/pages/admin_riwayat_page.dart';
import 'package:jti_reports/features/admin/pages/admin_setting_page.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 1;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> adminPages = [
      AdminRiwayatPage(onTabChange: _changeTab),
      AdminHomePage(onTabChange: _changeTab),
      AdminSettingPage(onTabChange: _changeTab),
    ];

    return Scaffold(
      extendBody: true,
      body: adminPages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.blue[800]!,
        buttonBackgroundColor: Colors.blue[800],
        height: 60,
        index: _selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.history, size: 30, color: Colors.white),
          Icon(Icons.home, size: 35, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        onTap: (index) => _changeTab(index),
      ),
    );
  }
}
