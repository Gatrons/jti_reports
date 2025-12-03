import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/widgets/appbar/main_app_bar.dart';
import '../../../core/widgets/drawer/main_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lokasi_page.dart'; // Pastikan file ini ada di folder pages

class TambahlaporanPage extends StatefulWidget {
  const TambahlaporanPage({super.key, required void Function(int index) onTabChange});

  @override
  State<TambahlaporanPage> createState() => _TambahlaporanPageState();
}

class _TambahlaporanPageState extends State<TambahlaporanPage> {
  // Controllers
  final TextEditingController _jenisKerusakanController =
      TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiDisplayController =
      TextEditingController(); // Hanya untuk menampilkan teks lokasi

  LokasiData? _selectedLocation;
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
              leading: const Icon(Icons.photo),
              title: const Text('Pilih Foto dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Pilih Video'),
              onTap: () async {
                Navigator.pop(context);
                await _pickVideo();
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
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.deepPurple.shade100),
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
    _lokasiDisplayController.dispose();
    super.dispose();
  }

  // --- NAVIGASI KE PETA ---
  void _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LokasiPage()),
    );

    if (result != null && result is LokasiData) {
      setState(() {
        _selectedLocation = result;
        // Update text field agar user melihat lokasi yang dipilih
        _lokasiDisplayController.text =
            "${result.namaLokasi} (${result.patokan})";
      });
    }
  }

  Future<void> uploadForm() async {
    try {
      // Simpan media ke folder lokal aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(p.join(appDir.path, 'laporan_media'));
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      List<String> mediaPaths = [];
      for (var media in _media) {
        final srcFile = File(media.path);
        final filename = '${DateTime.now().millisecondsSinceEpoch}_${media.name}';
        final destPath = p.join(mediaDir.path, filename);
        final copied = await srcFile.copy(destPath);
        mediaPaths.add(copied.path);
      }

      // Simpan data laporan ke Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'jenis_kerusakan': _jenisKerusakanController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _selectedLocation != null
            ? {
                'nama_lokasi': _selectedLocation!.namaLokasi,
                'patokan': _selectedLocation!.patokan,
                'latitude': _selectedLocation!.latitude,
                'longitude': _selectedLocation!.longitude,
              }
            : null,
        'tingkat_keparahan': _selectedSeverity,
        'media_paths': mediaPaths,
        'status': 'Diajukan',
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Besar
            const Text(
              "Detail Laporan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
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
            GestureDetector(
              onTap: _openLocationPicker,
              child: AbsorbPointer(
                // Mencegah keyboard muncul
                child: _buildTextField(
                  controller: _lokasiDisplayController,
                  hint: "Pilih lokasi fasilitas...",
                  icon: Icons.location_on,
                  isLocation: true,
                ),
              ),
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
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.transparent),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedSeverity,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.deepPurple,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Pilih tingkat keparahan",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.deepPurple,
                  ),
                  items: _severityOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.deepPurple),
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
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100),
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
                                        color: Colors.deepPurple.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
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
                            color: Colors.deepPurple.shade300,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Unggah atau Pilih Foto/Video (maks 3)",
                            style: TextStyle(
                              color: Colors.deepPurple,
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
                    _lokasiDisplayController.clear();
                    _deskripsiController.clear();
                    _selectedSeverity = null;
                    _selectedLocation = null;
                    _media.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
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
        style: const TextStyle(
          color: Colors.deepPurple,
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
        color: Colors.deepPurple.shade50, // Warna background input field
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: isLocation, // Readonly jika ini field lokasi
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.deepPurple, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),
        ),
      ),
    );
  }
}
