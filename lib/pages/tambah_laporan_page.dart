import 'package:flutter/material.dart';
import 'lokasi_page.dart'; // Pastikan file ini ada di folder pages

class TambahlaporanPage extends StatefulWidget {
  const TambahlaporanPage({super.key});

  @override
  State<TambahlaporanPage> createState() => _TambahlaporanPageState();
}

class _TambahlaporanPageState extends State<TambahlaporanPage> {
  // Controllers
  final TextEditingController _jenisKerusakanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _lokasiDisplayController = TextEditingController(); // Hanya untuk menampilkan teks lokasi

  LokasiData? _selectedLocation;
  String? _selectedSeverity;
  
  // List Dummy Media (String path gambar asset/dummy)
  // Kita pakai list string untuk simulasi, nanti diganti XFile dari image_picker
  List<String> _dummyMedia = []; 

  final List<String> _severityOptions = ['Rendah', 'Sedang', 'Tinggi', 'Bahaya'];

  @override
  void dispose() {
    _jenisKerusakanController.dispose();
    _deskripsiController.dispose();
    _lokasiDisplayController.dispose();
    super.dispose();
  }

  // --- LOGIC DUMMY FOTO/VIDEO ---
  void _addDummyMedia(String type) {
    setState(() {
      // Simulasi menambah file dummy ke list
      if (type == 'video') {
        _dummyMedia.add('video_placeholder'); // Penanda ini video
      } else {
        _dummyMedia.add('image_placeholder'); // Penanda ini gambar
      }
    });
    Navigator.pop(context); // Tutup modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Media dummy berhasil ditambahkan!")),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tambah Foto/Video (Simulasi)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
              title: const Text("Ambil Foto (Kamera)"),
              onTap: () => _addDummyMedia('image'),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.deepPurple),
              title: const Text("Pilih dari Galeri"),
              onTap: () => _addDummyMedia('image'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.deepPurple),
              title: const Text("Rekam Video"),
              onTap: () => _addDummyMedia('video'),
            ),
          ],
        ),
      ),
    );
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
        _lokasiDisplayController.text = "${result.namaLokasi} (${result.patokan})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih seperti di gambar
      appBar: AppBar(
        title: const Text(
          'Pengajuan Laporan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back default karena di tab utama
      ),
      // Tambahkan padding bawah agar tidak tertutup navbar
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
              child: AbsorbPointer( // Mencegah keyboard muncul
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
                      Icon(Icons.warning_amber_rounded, color: Colors.deepPurple, size: 22),
                      const SizedBox(width: 12),
                      Text("Pilih tingkat keparahan", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                  items: _severityOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.deepPurple)),
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
                  if (_dummyMedia.isEmpty) ...[
                    // Tampilan Kosong (Default seperti gambar)
                    GestureDetector(
                      onTap: _showMediaPicker,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Icon(Icons.camera_alt_outlined, size: 50, color: Colors.deepPurple.shade300),
                          const SizedBox(height: 10),
                          const Text(
                            "Unggah atau Pilih Foto Kerusakan",
                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Tampilan Grid (Jika sudah ada foto/video dummy)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ..._dummyMedia.map((media) => _buildMediaThumbnail(media)),
                        // Tombol Tambah Lagi
                        if (_dummyMedia.length < 3)
                          GestureDetector(
                            onTap: _showMediaPicker,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.deepPurple.shade200),
                              ),
                              child: const Icon(Icons.add, color: Colors.deepPurple),
                            ),
                          ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Laporan berhasil dikirim (Simulasi)")),
                  );
                  // Reset form dummy
                  setState(() {
                    _dummyMedia.clear();
                    _jenisKerusakanController.clear();
                    _lokasiDisplayController.clear();
                    _deskripsiController.clear();
                    _selectedSeverity = null;
                    _selectedLocation = null;
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
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }

  Widget _buildMediaThumbnail(String type) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.deepPurple),
          ),
          child: Center(
            child: Icon(
              type == 'video' ? Icons.videocam : Icons.image,
              color: Colors.deepPurple,
              size: 30,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _dummyMedia.remove(type); // Hapus item dummy
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}