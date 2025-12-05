import 'package:flutter/material.dart';
import 'package:jti_reports/features/profile/modal/change_class_modal.dart';
import 'package:jti_reports/features/profile/modal/change_gender_modal.dart';
import 'package:jti_reports/features/profile/modal/change_name_modal.dart';
import 'package:jti_reports/features/profile/modal/change_nim_modal.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? selectedGender = "Laki-laki";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Ubah Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 40),
        _buildProfileCard(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.blue[600],
      child: Center(child: _buildAvatar()),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blue,
            child: Text(
              "A",
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 8,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.black87,
            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem("Nama", "Anonim", () => ChangeNameModal.show(context)),
          _divider(),

          _buildItem("NIM", "2341760000", () => ChangeNimModal.show(context)),
          _divider(),

          _buildItem("Kelas", "SIB3C", () => ChangeClassModal.show(context)),
          _divider(),

          _buildItem(
            "Jenis Kelamin",
            "Laki-laki",
            () {
              ChangeGenderModal.show(context, "Laki-laki");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String value, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.black45),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
