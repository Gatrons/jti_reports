import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:jti_reports/core/widgets/appbar/main_app_bar.dart';
import 'package:jti_reports/core/widgets/drawer/main_drawer.dart';
import 'package:jti_reports/features/auth/services/auth_service.dart';
import 'package:jti_reports/features/auth/models/user_model.dart';

class FiveManageService {
  static const String _apiToken = 'YOUR_FIVEMANAGE_API_TOKEN';
  static const String _baseUrl = 'https://fmapi.net';

  static Future<String> uploadImage(File file) async {
    final uri = Uri.parse('$_baseUrl/api/v2/image');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = _apiToken
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Upload gagal: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null || data['url'] == null) {
      throw Exception(
        'Response Fivemanage tidak berisi data.url: ${response.body}',
      );
    }

    return data['url'] as String;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _authService.currentUserId;
      if (uid == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = await _authService.getUserData(uid);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
    }
  }

  Future<void> _updatePhotoProfile() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final uploadedUrl = await FiveManageService.uploadImage(file);

      final uid = _authService.currentUserId;
      if (uid == null) throw Exception('User tidak ditemukan');

      await _authService.updateUserProfile(uid, {'photoURL': uploadedUrl});

      setState(() {
        _user = _user?.copyWith(photoURL: uploadedUrl);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate foto profil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _user;

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const MainAppBar(title: 'Profil'),
      backgroundColor: Colors.grey[50],
      body: user == null ? _buildNoUser() : _buildProfileContent(user),
    );
  }

  Widget _buildNoUser() {
    return const Center(child: Text('Data user tidak ditemukan'));
  }

  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeader(user),
          const SizedBox(height: 24),
          _buildInfoCard(user),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    final photoUrl = user.photoURL;

    return Column(
      children: [
        GestureDetector(
          onTap: _updatePhotoProfile,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.deepPurple.shade100,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                ? NetworkImage(photoUrl)
                : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _updatePhotoProfile,
          icon: const Icon(Icons.camera_alt_outlined, size: 18),
          label: const Text('Ubah Foto Profil'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Nama', user.name, Icons.person_outline),
          const Divider(),
          _buildInfoRow('Email', user.email, Icons.email_outlined),
          const Divider(),
          _buildInfoRow('Role', user.role, Icons.verified_user_outlined),
          const Divider(),
          _buildInfoRow(
            'Verifikasi Email',
            user.emailVerified ? 'Sudah diverifikasi' : 'Belum diverifikasi',
            user.emailVerified ? Icons.check_circle : Icons.error_outline,
            iconColor: user.emailVerified ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
