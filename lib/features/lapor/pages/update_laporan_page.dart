import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'lokasi_page.dart';

class UpdateLaporanPage extends StatefulWidget {
  final String docId;
  final String initialJenis;
  final String initialDeskripsi;
  final Map<String, dynamic>? initialLokasi;
  final String? initialSeverity;
  final List<String>? initialMediaPaths;

  const UpdateLaporanPage({
    Key? key,
    required this.docId,
    required this.initialJenis,
    required this.initialDeskripsi,
    this.initialLokasi,
    this.initialSeverity,
    this.initialMediaPaths,
  }) : super(key: key);

  @override
  State<UpdateLaporanPage> createState() => _UpdateLaporanPageState();
}

class _UpdateLaporanPageState extends State<UpdateLaporanPage> {
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiDisplayController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final int _maxMedia = 3;

  Map<String, dynamic>? _lokasi;
  String? _selectedSeverity;
  // path media yang sudah tersimpan
  List<String> _existingMedia = [];
  // path media baru yang dipilih
  List<XFile> _newMedia = [];

  @override
  void initState() {
    super.initState();
    _jenisController.text = widget.initialJenis;
    _deskripsiController.text = widget.initialDeskripsi;
    _lokasi = widget.initialLokasi != null ? Map<String, dynamic>.from(widget.initialLokasi!) : null;
    _selectedSeverity = widget.initialSeverity;
    _existingMedia = widget.initialMediaPaths != null ? List<String>.from(widget.initialMediaPaths!) : [];
    _lokasiDisplayController.text = _lokasi != null
        ? (_lokasi!['patokan'] ?? _lokasi!['nama_lokasi'] ?? '')
        : '';
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _deskripsiController.dispose();
    _lokasiDisplayController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = _maxMedia - (_existingMedia.length + _newMedia.length);
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 3 media')));
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked == null || picked.isEmpty) return;
      final toAdd = picked.take(remaining).toList();
      setState(() => _newMedia.addAll(toAdd));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _pickVideo() async {
    final remaining = _maxMedia - (_existingMedia.length + _newMedia.length);
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimum 3 media')));
      return;
    }
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
      if (picked == null) return;
      setState(() => _newMedia.add(picked));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih video: $e')));
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
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Pilih Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
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

  void _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LokasiPage()),
    );
    if (result != null && result is LokasiData) {
      setState(() {
        _lokasi = {
          'nama_lokasi': result.namaLokasi,
          'patokan': result.patokan,
          'latitude': result.latitude,
          'longitude': result.longitude,
        };
        _lokasiDisplayController.text = "${result.namaLokasi} (${result.patokan})";
      });
    }
  }

  Widget _buildMediaThumbnailFromPath(String path, int idx) {
    final lower = path.toLowerCase();
    final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv');
    final isNetwork = path.startsWith('http') || path.startsWith('https');

    Widget thumb;
    if (isNetwork) {
      if (isVideo) thumb = Container(color: Colors.black54, child: const Icon(Icons.videocam, color: Colors.white));
      else thumb = Image.network(path, fit: BoxFit.cover);
    } else {
      final file = File(path);
      if (!file.existsSync()) {
        thumb = const Center(child: Icon(Icons.broken_image, size: 30));
      } else if (isVideo) {
        thumb = Container(color: Colors.black54, child: const Icon(Icons.videocam, color: Colors.white));
      } else {
        thumb = Image.file(file, fit: BoxFit.cover);
      }
    }

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
          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: thumb),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _existingMedia.removeAt(idx);
              });
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMediaThumbnailFromXFile(XFile media, int idx) {
    final lower = media.path.toLowerCase();
    final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi') || lower.endsWith('.mkv');

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
            child: isVideo ? Container(color: Colors.black54, child: const Icon(Icons.videocam, color: Colors.white)) : Image.file(File(media.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _newMedia.removeAt(idx);
              });
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _submitUpdate() async {
    try {
      // copy new media to aplikasi local
      final appDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(p.join(appDir.path, 'laporan_media'));
      if (!await mediaDir.exists()) await mediaDir.create(recursive: true);

      final List<String> finalMediaPaths = List<String>.from(_existingMedia);
      for (var media in _newMedia) {
        final src = File(media.path);
        final filename = '${DateTime.now().millisecondsSinceEpoch}_${media.name}';
        final dest = p.join(mediaDir.path, filename);
        final copied = await src.copy(dest);
        finalMediaPaths.add(copied.path);
      }

      // update Firestore doc
      await FirebaseFirestore.instance.collection('reports').doc(widget.docId).update({
        'jenis_kerusakan': _jenisController.text,
        'deskripsi': _deskripsiController.text,
        'lokasi': _lokasi,
        'tingkat_keparahan': _selectedSeverity,
        'media_paths': finalMediaPaths,
        'status': 'Diajukan',
        'updated_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan berhasil diperbarui')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui laporan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityOptions = ['Rendah', 'Sedang', 'Tinggi', 'Bahaya'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Update Laporan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Detail Laporan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 20),

          _buildLabel('Jenis Kerusakan'),
          _buildTextField(controller: _jenisController, hint: 'Contoh: AC Mati, Kursi Patah', icon: Icons.build),

          const SizedBox(height: 15),
          _buildLabel('Lokasi Fasilitas'),
          GestureDetector(
            onTap: _openLocationPicker,
            child: AbsorbPointer(
              child: _buildTextField(controller: _lokasiDisplayController, hint: 'Pilih lokasi fasilitas...', icon: Icons.location_on, isLocation: true),
            ),
          ),

          const SizedBox(height: 15),
          _buildLabel('Deskripsi Kerusakan'),
          _buildTextField(controller: _deskripsiController, hint: 'Tuliskan penjelasan singkat kerusakan', icon: Icons.description),

          const SizedBox(height: 15),
          _buildLabel('Tingkat Keparahan'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedSeverity,
                hint: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.deepPurple, size: 22), const SizedBox(width: 12), Text('Pilih tingkat keparahan', style: TextStyle(color: Colors.grey[600], fontSize: 14))]),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                items: severityOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.deepPurple)))).toList(),
                onChanged: (val) => setState(() => _selectedSeverity = val),
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildLabel('Gambar Pendukung'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: Column(children: [
              if (_existingMedia.isNotEmpty || _newMedia.isNotEmpty) ...[
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingMedia.length + _newMedia.length + ((_existingMedia.length + _newMedia.length) < _maxMedia ? 1 : 0),
                    itemBuilder: (context, idx) {
                      if (idx < _existingMedia.length) {
                        return _buildMediaThumbnailFromPath(_existingMedia[idx], idx);
                      } else if (idx < _existingMedia.length + _newMedia.length) {
                        return _buildMediaThumbnailFromXFile(_newMedia[idx - _existingMedia.length], idx - _existingMedia.length);
                      } else {
                        return GestureDetector(
                          onTap: _showMediaPickerSheet,
                          child: Container(width: 80, height: 80, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.deepPurple.shade100, borderRadius: BorderRadius.circular(10)), child: const Center(child: Icon(Icons.add, color: Colors.white))),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[     
                  GestureDetector(
                    onTap: _showMediaPickerSheet,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                  ),
                ),
              ],
            ]),
          ),

          const SizedBox(height: 40),
          SizedBox(height: 55, width: double.infinity, child: ElevatedButton(onPressed: _submitUpdate, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2), child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
        ]),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 4.0), child: Text(text, style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 15)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isLocation = false}) {
    return Container(decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)), child: TextField(controller: controller, readOnly: isLocation, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14), prefixIcon: Icon(icon, color: Colors.deepPurple, size: 22), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10))));
  }
}