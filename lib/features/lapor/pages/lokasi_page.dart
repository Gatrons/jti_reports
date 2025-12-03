import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // Channel komunikasi Flutter <-> Android (osmdroid)
  static const MethodChannel _osmChannel =
      MethodChannel('com.example.jti_reports/osm_location');

  final TextEditingController _patokanController = TextEditingController();

  bool _isLoading = false;
  String _statusGps = "Belum ada lokasi yang dipilih.";
  double _lat = 0.0;
  double _long = 0.0;

  @override
  void dispose() {
    _patokanController.dispose();
    super.dispose();
  }

  /// Buka MapActivity (OSM) di Android native dan ambil koordinat yang dipilih
  Future<void> _bukaPetaOsmDanAmbilLokasi() async {
    setState(() {
      _isLoading = true;
      _statusGps = "Membuka peta OSM dan mencari lokasi...";
    });

    try {
      // Panggil method native: pickLocationOnMap
      final result =
          await _osmChannel.invokeMethod<Map<dynamic, dynamic>>('pickLocationOnMap');

      if (!mounted) return;

      if (result != null &&
          result['lat'] != null &&
          result['lng'] != null) {
        final double lat = (result['lat'] as num).toDouble();
        final double lng = (result['lng'] as num).toDouble();

        setState(() {
          _lat = lat;
          _long = lng;
          _statusGps = "Lokasi Terkunci (diambil dari peta OSM)";
          _isLoading = false;
        });
      } else {
        // User mungkin keluar dari peta tanpa memilih lokasi
        setState(() {
          _statusGps = "Lokasi tidak jadi dipilih.";
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _statusGps = "Gagal mengambil lokasi dari OSM: ${e.message}";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusGps = "Terjadi kesalahan saat mengambil lokasi.";
        _isLoading = false;
      });
    }
  }

  void _simpanLokasi() {
    // Pastikan sudah ada koordinat valid
    if (_lat == 0.0 && _long == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih lokasi terlebih dahulu.")),
      );
      return;
    }

    final data = LokasiData(
      latitude: _lat,
      longitude: _long,
      // Untuk sekarang, namaLokasi bisa diset sementara.
      // Kalau nanti di Android kamu kirim juga nama/patokannya, tinggal diganti.
      namaLokasi: "Lokasi dipilih via peta OSM",
      patokan: _patokanController.text,
    );

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final bool sudahAdaLokasi = _lat != 0.0 || _long != 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pilih Lokasi Fasilitas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container "peta" yang sekarang terhubung ke OSM via native
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
                          const CircularProgressIndicator(
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _statusGps,
                            style: TextStyle(color: Colors.deepPurple.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            sudahAdaLokasi
                                ? Icons.location_on
                                : Icons.map_outlined,
                            size: 50,
                            color: sudahAdaLokasi ? Colors.red : Colors.deepPurple,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _statusGps,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          if (sudahAdaLokasi)
                            Text(
                              "Lat: $_lat, Long: $_long",
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          else
                            Text(
                              "Tekan tombol di bawah untuk membuka peta OSM.",
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol untuk membuka peta OSM dan ambil lokasi
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _bukaPetaOsmDanAmbilLokasi,
                icon: const Icon(Icons.my_location),
                label: const Text("Gunakan Lokasi Saat Ini via Peta OSM"),
              ),
            ),

            const SizedBox(height: 20),

            // Input Patokan
            const Text(
              "Patokan Lokasi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
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
                  borderSide:
                      const BorderSide(color: Colors.deepPurple, width: 2),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Gunakan Lokasi Ini",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
}
