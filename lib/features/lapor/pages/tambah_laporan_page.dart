import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/widgets/appbar/main_app_bar.dart';
import '../../../core/widgets/drawer/main_drawer.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahlaporanPage extends StatefulWidget {
  const TambahlaporanPage({
    super.key,
    required void Function(int index) onTabChange,
  });

  @override
  State<TambahlaporanPage> createState() => _TambahlaporanPageState();
}

class _TambahlaporanPageState extends State<TambahlaporanPage> {
  // Controllers
  final TextEditingController _jenisKerusakanController =
      TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  String? _selectedSeverity;
  final ImagePicker _picker = ImagePicker();
  final int _maxMedia = 3;
  List<XFile> _media = [];

  // Fungsi pick image & setState
  Future<void> _pickImages() async {
    final remaining = _maxMedia - _media.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimum 3 media")));
      return;
    }
    try {
      final List<XFile>? picked = await _picker.pickMultiImage(
        imageQuality: 80,
      );
      if (picked == null || picked.isEmpty) return;
      setState(() {
        final toAdd = picked.take(remaining).toList();
        _media.addAll(toAdd);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _pickVideo() async {
    final remaining = _maxMedia - _media.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimum 3 media")));
      return;
    }
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );
      if (picked == null) return;
      setState(() => _media.add(picked));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih video: $e')));
    }
  }

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickCameraImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Rekam Video'),
              onTap: () async {
                Navigator.pop(context);
                await _pickCameraVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Pilih Foto dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(XFile media, int index) {
    final pathLower = media.path.toLowerCase();
    final isVideo =
        pathLower.endsWith('.mp4') ||
        pathLower.endsWith('.mov') ||
        pathLower.endsWith('.avi') ||
        pathLower.endsWith('.mkv');

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isVideo
                ? Stack(
                    children: [
                      // Simpel preview untuk video: tampilkan ikon video
                      Container(color: Colors.black54),
                      const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    File(media.path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _media.removeAt(index);
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  final List<String> _severityOptions = [
    'Rendah',
    'Sedang',
    'Tinggi',
    'Bahaya',
  ];

  @override
  void dispose() {
    _jenisKerusakanController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> uploadForm() async {
    // Validasi semua field harus terisi
    if (_jenisKerusakanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis kerusakan harus diisi')),
      );
      return;
    }

    if (_lokasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi fasilitas harus diisi')),
      );
      return;
    }

    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi kerusakan harus diisi')),
      );
      return;
    }

    if (_selectedSeverity == null || _selectedSeverity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tingkat keparahan harus dipilih')),
      );
      return;
    }

    try {
      // Simpan media ke Supabase Storage
      final supabase = Supabase.instance.client;
      const String bucket = 'laporan-media';
      List<String> mediaUrls = [];

      // Upload setiap media ke Supabase storage dan ambil public URL
      for (var media in _media) {
        final file = File(media.path);
        final filename =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(media.path)}';
        final storagePath = 'reports/$filename';

        final bytes = await file.readAsBytes();

        await supabase.storage.from(bucket).uploadBinary(storagePath, bytes);

        // dapatkan public URL
        final publicUrl = supabase.storage
            .from(bucket)
            .getPublicUrl(storagePath);
        mediaUrls.add(publicUrl);
      }

      // Simpan data laporan ke Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'jenis_kerusakan': _jenisKerusakanController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _lokasiController.text,
        'tingkat_keparahan': _selectedSeverity,
        'media_paths': mediaUrls,
        'status': 'Diajukan',
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'is_read': true,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Laporan berhasil dikirim")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: const MainAppBar(title: 'Lapor Fasilitas'),
      backgroundColor: Colors.indigo[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Besar
            Text(
              "Detail Laporan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Jenis Kerusakan
            _buildLabel("Jenis Kerusakan"),
            _buildTextField(
              controller: _jenisKerusakanController,
              hint: "Contoh: AC Mati, Kursi Patah, ...",
              icon: Icons.build,
            ),
            const SizedBox(height: 15),

            // 2. Lokasi Fasilitas (Read Only - Tap to Pick)
            _buildLabel("Lokasi Fasilitas"),
            _buildTextField(
              controller: _lokasiController,
              hint: "Contoh: LPR1-LT7B",
              icon: Icons.location_on,
            ),
            const SizedBox(height: 15),

            // 3. Deskripsi Kerusakan
            _buildLabel("Deskripsi Kerusakan"),
            _buildTextField(
              controller: _deskripsiController,
              hint: "Tuliskan penjelasan singkat kerusakan",
              icon: Icons.description,
            ),
            const SizedBox(height: 15),

            // 4. Tingkat Keparahan (Dropdown)
            _buildLabel("Tingkat Keparahan"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSeverity,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.blue[800],
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Pilih tingkat keparahan",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
                  items: _severityOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSeverity = val),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 5. Upload Foto/Media Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showMediaPickerSheet,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Jika ada media tampilkan thumbnail list
                        if (_media.isNotEmpty) ...[
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  _media.length +
                                  (_media.length < _maxMedia ? 1 : 0),
                              itemBuilder: (context, idx) {
                                if (idx < _media.length) {
                                  final m = _media[idx];
                                  return _buildMediaThumbnail(m, idx);
                                } else {
                                  // Tombol tambah
                                  return GestureDetector(
                                    onTap: _showMediaPickerSheet,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ] else ...[
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 50,
                            color: Colors.blue[800],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Unggah atau Pilih Foto/Video (maks 3)",
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  await uploadForm();
                  setState(() {
                    _jenisKerusakanController.clear();
                    _lokasiController.clear();
                    _deskripsiController.clear();
                    _selectedSeverity = null;
                    _media.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Kirim Laporan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isLocation = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Warna background input field
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        readOnly: isLocation, // Readonly jika ini field lokasi
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.blue[800], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  Future<void> _pickCameraImage() async {
    final remaining = _maxMedia - _media.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimum 3 media")));
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _media.add(picked);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }

  Future<void> _pickCameraVideo() async {
    final remaining = _maxMedia - _media.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maksimum 3 media")));
      return;
    }

    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );

      if (picked == null) return;

      setState(() {
        _media.add(picked);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }
}
