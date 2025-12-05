import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jti_reports/features/riwayat/pages/media_viewer.dart';
import 'package:jti_reports/features/lapor/pages/update_laporan_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailLaporanPage extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final String deskripsi;
  final String keparahan;
  final Map<String, dynamic>? lokasi;
  final List<String>? mediaPaths;
  final String? docId;

  const DetailLaporanPage({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.deskripsi,
    required this.keparahan,
    this.lokasi,
    this.mediaPaths,
    this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final lokasiText = lokasi != null
        ? (lokasi!['patokan'] ??
              lokasi!['nama_lokasi'] ??
              'Lokasi tidak tersedia')
        : 'Lokasi tidak tersedia';

    final lat = lokasi != null
        ? (lokasi!['latitude'] as num?)?.toDouble()
        : null;
    final lon = lokasi != null
        ? (lokasi!['longitude'] as num?)?.toDouble()
        : null;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),

      backgroundColor: Colors.indigo[50],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (mediaPaths != null && mediaPaths!.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mediaPaths!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = mediaPaths![i];
                  final lower = p.toLowerCase();
                  final isVideo =
                      lower.endsWith('.mp4') ||
                      lower.endsWith('.mov') ||
                      lower.endsWith('.avi') ||
                      lower.endsWith('.mkv');
                  final isNetwork =
                      p.startsWith('http') || p.startsWith('https');

                  Widget thumb;
                  if (isNetwork) {
                    if (isVideo) {
                      thumb = Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white70,
                            size: 46,
                          ),
                        ),
                      );
                    } else {
                      thumb = Image.network(p, fit: BoxFit.cover);
                    }
                  } else {
                    final f = File(p);
                    if (!f.existsSync()) {
                      thumb = const Center(
                        child: Icon(Icons.broken_image, size: 36),
                      );
                    } else if (isVideo) {
                      thumb = Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 46,
                          ),
                        ),
                      );
                    } else {
                      thumb = Image.file(f, fit: BoxFit.cover);
                    }
                  }

                  return GestureDetector(
                    onTap: () => _openMedia(context, p, isVideo),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 180,
                        height: 220,
                        color: Colors.deepPurple.shade50,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            thumb,
                            if (isVideo)
                              const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_circle_outline,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Gambar Pendukung",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          _buildInfo("Judul Laporan", title),
          _buildInfo("Tanggal", date),
          _buildInfo("Status", status, color: statusColor),
          _buildInfo("Deskripsi", deskripsi),
          _buildInfo("Tingkat Keparahan", keparahan),
          _buildInfo("Lokasi", lokasiText),
          if (lat != null && lon != null)
            _buildInfo("Koordinat", "Lat: $lat, Lon: $lon"),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: docId == null
                      ? null
                      : () async {
                          final updated = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UpdateLaporanPage(
                                docId: docId!,
                                initialJenis: title,
                                initialDeskripsi: deskripsi,
                                initialLokasi: lokasi,
                                initialSeverity: keparahan,
                                initialMediaPaths: mediaPaths,
                              ),
                            ),
                          );
                          if (updated == true) {
                            Navigator.of(context).pop();
                          }
                        },
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text(
                    'Update',
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: docId == null
                      ? null
                      : () => _confirmDelete(context),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  void _openMedia(BuildContext context, String path, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewerPage(path: path, isVideo: isVideo),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (docId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Laporan'),
          content: const Text(
            'Anda yakin ingin menghapus laporan ini? Aksi ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      _deleteReport(context);
    }
  }

  Future<void> _deleteReport(BuildContext context) async {
    if (docId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dihapus')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus laporan: $e')));
    }
  }
}
