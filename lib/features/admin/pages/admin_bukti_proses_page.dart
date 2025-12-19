import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBuktiProsesPage extends StatefulWidget {
  final String docId;
  final String newStatus;

  const AdminBuktiProsesPage({
    Key? key,
    required this.docId,
    required this.newStatus,
  }) : super(key: key);

  @override
  State<AdminBuktiProsesPage> createState() => AdminBuktiProsesPageState();
}

class AdminBuktiProsesPageState extends State<AdminBuktiProsesPage> {
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.newStatus;
  }


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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitBukti() async {
    try {
      if (_media.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Silakan pilih minimal satu media sebagai bukti proses',
            ),
          ),
        );
        return;
      }

      final supabase = Supabase.instance.client;
      const String bucket = 'laporan-media';
      List<String> mediaUrls = [];

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

      // update Firestore doc
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.docId)
          .update({
            'bukti_paths': mediaUrls,
            'status': status,
            'updated_at': FieldValue.serverTimestamp(),
            'is_read': false,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah: $status')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui laporan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Upload Bukti Proses',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      backgroundColor: Colors.indigo[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambahkan Gambar / Video',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 20),
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
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBukti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan',
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
