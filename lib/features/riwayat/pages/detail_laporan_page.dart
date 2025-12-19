import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jti_reports/features/riwayat/pages/media_viewer.dart';
import 'package:jti_reports/features/lapor/pages/update_laporan_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailLaporanPage extends StatefulWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final String deskripsi;
  final String keparahan;
  final String lokasi;
  final List<String>? mediaPaths;
  final String docId;
  final List<String>? buktiPaths;

  const DetailLaporanPage({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.deskripsi,
    required this.keparahan,
    required this.lokasi,
    this.mediaPaths,
    required this.docId,
    this.buktiPaths,
  });

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  String _userRole = 'user';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _userRole = 'user');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final role = userDoc.data()?['role'] as String? ?? 'user';
      if (mounted) {
        setState(() => _userRole = role);
      }
    } catch (e) {
      print('Error fetching user role: $e');
      if (mounted) {
        setState(() => _userRole = 'user');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final date = widget.date;
    final status = widget.status;
    final statusColor = widget.statusColor;
    final deskripsi = widget.deskripsi;
    final keparahan = widget.keparahan;
    final lokasi = widget.lokasi;
    final mediaPaths = widget.mediaPaths;
    final docId = widget.docId;
    final buktiPaths = widget.buktiPaths;
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
          if (mediaPaths != null && mediaPaths.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: mediaPaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = mediaPaths[i];
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Tidak Ada Gambar Pendukung",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[800],
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
          _buildInfo("Lokasi", lokasi),
          const SizedBox(height: 20),

          if (buktiPaths != null && buktiPaths.isNotEmpty) 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bukti Proses",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: buktiPaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final path = buktiPaths[i];
                      final isNetwork = path.startsWith('http') || path.startsWith('https');
                      Widget thumb;

                      if (isNetwork) {
                        thumb = Image.network(path, fit: BoxFit.cover);
                      } else {
                        final f = File(path);
                        if (!f.existsSync()) {
                          thumb = const Center(child: Icon(Icons.broken_image, size: 36));
                        } else {
                          thumb = Image.file(f, fit: BoxFit.cover);
                        }
                      }

                      return GestureDetector(
                        onTap: () => _openMedia(context, path, false), // False for images
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 180,
                            height: 220,
                            color: Colors.grey[50],
                            child: thumb,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 20),

          if (status == 'Diajukan' && _userRole != 'admin')
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
                                  docId: widget.docId,
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
    if (widget.docId == null) return;
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
    if (widget.docId == null) return;
    try {
      // Hapus media dari Supabase (jika ada)
      if (widget.mediaPaths != null && widget.mediaPaths!.isNotEmpty) {
        const bucket = 'laporan-media';
        for (final url in widget.mediaPaths!) {
          if (url.startsWith('http')) {
            try {
              final uri = Uri.parse(url);
              final segments = uri.pathSegments;
              final publicIdx = segments.indexOf('public');
              if (publicIdx >= 0 && publicIdx + 2 < segments.length) {
                final filePath = segments.skip(publicIdx + 2).join('/');
                await Supabase.instance.client.storage.from(bucket).remove([filePath]);
              } else {
                print('Could not extract storage path from url: $url');
              }
            } catch (e) {
              // log and continue deleting other files
              print('Gagal menghapus media dari Supabase: $e');
            }
          }
        }
      }
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.docId)
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
