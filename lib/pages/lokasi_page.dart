import 'package:flutter/material.dart';

// Model data lokasi
class LokasiData {
  final double latitude;
  final double longitude;
  final String namaLokasi;
  final String patokan;

  LokasiData({
    required this.latitude,
    required this.longitude,
    required this.namaLokasi,
    required this.patokan,
  });
}

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _PilihLokasiPageState();
}

class _PilihLokasiPageState extends State<LokasiPage> {
  final TextEditingController _patokanController = TextEditingController();

  // Variable state untuk simulasi
  bool _isLoading = true;
  String _statusGps = "Sedang mencari satelit GPS...";
  double _lat = 0.0;
  double _long = 0.0;

  @override
  void initState() {
    super.initState();
    _simulasiAmbilGPS();
  }

  // Fungsi Dummy untuk simulasi delay GPS
  Future<void> _simulasiAmbilGPS() async {
    await Future.delayed(const Duration(seconds: 2)); // Pura-pura loading 2 detik
    if (mounted) {
      setState(() {
        _lat = -7.9419; // Koordinat contoh (JTI Polinema)
        _long = 112.6161;
        _statusGps = "Lokasi Terkunci (Akurasi Tinggi)";
        _isLoading = false;
      });
    }
  }

  void _simpanLokasi() {
    if (_lat == 0.0) return;

    final data = LokasiData(
      latitude: _lat,
      longitude: _long,
      namaLokasi: "Gedung Sipil Lt. 6 (Dummy GPS)", // Nama lokasi dummy
      patokan: _patokanController.text,
    );

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Lokasi Fasilitas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container Peta Dummy
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Center(
                child: _isLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.deepPurple),
                          const SizedBox(height: 10),
                          Text(_statusGps, style: TextStyle(color: Colors.deepPurple.shade700)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 50, color: Colors.red),
                          const SizedBox(height: 10),
                          Text(_statusGps, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          Text("Lat: $_lat, Long: $_long", style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Input Patokan
            const Text("Patokan Lokasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _patokanController,
              decoration: InputDecoration(
                hintText: "Contoh: Depan lift dosen, sebelah tangga...",
                filled: true,
                fillColor: Colors.deepPurple.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
              ),
              maxLines: 2,
            ),
            const Spacer(),
            
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanLokasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Gunakan Lokasi Ini", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}