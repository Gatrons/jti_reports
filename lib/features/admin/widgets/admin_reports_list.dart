import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// =======================
///  USER NAME CACHE
/// =======================
class _UserNameCache {
  final Map<String, Future<String>> _cache = {};

  Future<String> getName(String uid) {
    return _cache.putIfAbsent(uid, () async {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = doc.data();
        if (data == null) return 'User tidak ditemukan';

        final name =
            (data['name'] ??
                    data['nama'] ??
                    data['displayName'] ??
                    data['full_name'] ??
                    '')
                .toString()
                .trim();

        return name.isEmpty ? 'Tanpa nama' : name;
      } catch (_) {
        return 'Gagal ambil nama';
      }
    });
  }
}

class AdminReportsList extends StatefulWidget {
  const AdminReportsList({super.key});

  @override
  State<AdminReportsList> createState() => _AdminReportsListState();
}

class _AdminReportsListState extends State<AdminReportsList> {
  final _searchC = TextEditingController();
  final _userNameCache = _UserNameCache();

  // filter
  String _filterStatus = 'Semua';
  String _filterKeparahan = 'Semua';
  String _filterJenis = 'Semua';

  final List<String> _statusOptions = const ['Diajukan', 'Diproses', 'Selesai'];

  final List<String> _filterStatusOptions = const [
    'Semua',
    'Diajukan',
    'Diproses',
    'Selesai',
  ];

  List<String> _keparahanOptions = const ['Semua'];
  List<String> _jenisOptions = const ['Semua'];

  String _lastOptionsSignature = '';

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  String _norm(dynamic v) => (v ?? '').toString().trim().toLowerCase();

  String _formatTanggal(dynamic timestamp) {
    try {
      DateTime dt;
      if (timestamp is Timestamp) {
        dt = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dt = timestamp;
      } else if (timestamp is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return timestamp?.toString() ?? '';
      }
      return DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return timestamp?.toString() ?? '';
    }
  }

  String _lokasiToDisplay(dynamic lokasiValue) {
    if (lokasiValue == null) return '-';
    if (lokasiValue is String)
      return lokasiValue.trim().isEmpty ? '-' : lokasiValue.trim();
    if (lokasiValue is Map) {
      final nama = (lokasiValue['nama_lokasi'] ?? '').toString().trim();
      final patokan = (lokasiValue['patokan'] ?? '').toString().trim();
      if (nama.isNotEmpty && patokan.isNotEmpty) return '$nama • $patokan';
      if (nama.isNotEmpty) return nama;
      if (patokan.isNotEmpty) return patokan;
      final lat = lokasiValue['latitude'];
      final lon = lokasiValue['longitude'];
      if (lat != null && lon != null) return 'GPS: $lat, $lon';
    }
    return lokasiValue.toString();
  }

  String? _thumbFromMedia(dynamic mediaPaths) {
    if (mediaPaths is! List) return null;
    if (mediaPaths.isEmpty) return null;
    final first = mediaPaths.first?.toString() ?? '';
    return first.startsWith('http') ? first : null;
  }

  Color _statusColor(String statusRaw) {
    final s = statusRaw.trim().toLowerCase();
    if (s == 'selesai') return Colors.green;
    if (s == 'diproses') return Colors.orange;
    return Colors.redAccent;
  }

  Color _severityColor(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'bahaya') return Colors.red;
    if (s == 'tinggi') return Colors.orange;
    if (s == 'rendah') return Colors.blue;
    return Colors.indigo;
  }

  void _scheduleOptionsUpdate(List<QueryDocumentSnapshot> docs) {
    final jenisSet = <String>{};
    final kepSet = <String>{};

    for (final d in docs) {
      final data = (d.data() as Map<String, dynamic>? ?? {});
      final jenis = (data['jenis_kerusakan'] ?? '').toString().trim();
      final kep = (data['tingkat_keparahan'] ?? '').toString().trim();
      if (jenis.isNotEmpty) jenisSet.add(jenis);
      if (kep.isNotEmpty) kepSet.add(kep);
    }

    final newJenis = ['Semua', ...jenisSet.toList()..sort()];
    final newKep = ['Semua', ...kepSet.toList()..sort()];

    final signature = '${newJenis.join("|")}__${newKep.join("|")}';
    if (signature == _lastOptionsSignature) return;
    _lastOptionsSignature = signature;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _jenisOptions = newJenis;
        _keparahanOptions = newKep;

        if (!_jenisOptions.contains(_filterJenis)) _filterJenis = 'Semua';
        if (!_keparahanOptions.contains(_filterKeparahan))
          _filterKeparahan = 'Semua';
      });
    });
  }

  bool _match(Map<String, dynamic> data, String userName) {
    final q = _norm(_searchC.text);

    final statusDb = _norm(data['status']);
    final kepDb = _norm(data['tingkat_keparahan']);
    final jenisDb = _norm(data['jenis_kerusakan']);

    final statusPick = _norm(_filterStatus);
    final kepPick = _norm(_filterKeparahan);
    final jenisPick = _norm(_filterJenis);

    if (statusPick != 'semua' && statusDb != statusPick) return false;
    if (kepPick != 'semua' && kepDb != kepPick) return false;
    if (jenisPick != 'semua' && jenisDb != jenisPick) return false;

    if (q.isEmpty) return true;

    final lokasi = _norm(_lokasiToDisplay(data['lokasi']));
    final deskripsi = _norm(data['deskripsi']);
    final nama = _norm(userName);

    return lokasi.contains(q) ||
        deskripsi.contains(q) ||
        jenisDb.contains(q) ||
        statusDb.contains(q) ||
        kepDb.contains(q) ||
        nama.contains(q);
  }

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('reports').doc(docId).update({
      'status': newStatus,
      'updated_at': FieldValue.serverTimestamp(), // optional tapi bagus
    });
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('reports').snapshots();

    return Column(
      children: [
        _buildSearch(),
        const SizedBox(height: 12),
        _buildFilters(),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Terjadi error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada laporan masuk'));
              }

              final docs = List<QueryDocumentSnapshot>.from(
                snapshot.data!.docs,
              );

              // sort newest (client-side)
              docs.sort((a, b) {
                final da = (a.data() as Map<String, dynamic>? ?? {});
                final db = (b.data() as Map<String, dynamic>? ?? {});
                final ta = da['timestamp'] is Timestamp
                    ? (da['timestamp'] as Timestamp).toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
                final tb = db['timestamp'] is Timestamp
                    ? (db['timestamp'] as Timestamp).toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
                return tb.compareTo(ta);
              });

              _scheduleOptionsUpdate(docs);

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final data = (doc.data() as Map<String, dynamic>? ?? {});
                  final uid = (data['user_id'] ?? '').toString().trim();

                  return FutureBuilder<String>(
                    future: uid.isEmpty
                        ? Future.value('Tanpa user')
                        : _userNameCache.getName(uid),
                    builder: (context, s) {
                      final userName =
                          s.data ??
                          (uid.isEmpty ? 'Tanpa user' : 'Memuat nama...');

                      if (!_match(data, userName))
                        return const SizedBox.shrink();

                      final judul =
                          data['jenis_kerusakan']?.toString() ?? 'Laporan';
                      final deskripsi = data['deskripsi']?.toString() ?? '-';
                      final status = data['status']?.toString() ?? 'Diajukan';
                      final keparahan =
                          data['tingkat_keparahan']?.toString() ?? '-';
                      final lokasi = _lokasiToDisplay(data['lokasi']);
                      final tanggal = _formatTanggal(data['timestamp']);
                      final thumb = _thumbFromMedia(data['media_paths']);

                      return _AdminReportCard(
                        title: judul,
                        deskripsi: deskripsi,
                        lokasi: lokasi,
                        tanggal: tanggal,
                        userName: userName,
                        status: status,
                        statusColor: _statusColor(status),
                        keparahan: keparahan,
                        severityColor: _severityColor(keparahan),
                        thumbUrl: thumb,

                        // ✅ admin edit status via dropdown
                        statusItems: _statusOptions,
                        onStatusChanged: (newStatus) async {
                          try {
                            await _updateStatus(doc.id, newStatus);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Status diubah: $newStatus'),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal ubah status: $e')),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchC,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari lokasi, deskripsi, nama user, jenis...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Dropdown(
                  label: 'Status',
                  value: _filterStatus,
                  items: _filterStatusOptions,
                  onChanged: (v) => setState(() => _filterStatus = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Dropdown(
                  label: 'Keparahan',
                  value: _keparahanOptions.contains(_filterKeparahan)
                      ? _filterKeparahan
                      : 'Semua',
                  items: _keparahanOptions,
                  onChanged: (v) => setState(() => _filterKeparahan = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Dropdown(
                  label: 'Jenis',
                  value: _jenisOptions.contains(_filterJenis)
                      ? _filterJenis
                      : 'Semua',
                  items: _jenisOptions,
                  onChanged: (v) => setState(() => _filterJenis = v),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filterStatus = 'Semua';
                    _filterKeparahan = 'Semua';
                    _filterJenis = 'Semua';
                    _searchC.clear();
                  });
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => v == null ? null : onChanged(v),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  final String title;
  final String deskripsi;
  final String lokasi;
  final String tanggal;
  final String userName;

  final String status;
  final Color statusColor;

  final String keparahan;
  final Color severityColor;

  final String? thumbUrl;

  // admin status dropdown
  final List<String> statusItems;
  final ValueChanged<String> onStatusChanged;

  const _AdminReportCard({
    required this.title,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggal,
    required this.userName,
    required this.status,
    required this.statusColor,
    required this.keparahan,
    required this.severityColor,
    required this.thumbUrl,
    required this.statusItems,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // pastiin value dropdown termasuk di items
    final currentStatus = statusItems.contains(status)
        ? status
        : statusItems.first;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(url: thumbUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[800]),
                ),
                const SizedBox(height: 10),

                // badges info
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      text: keparahan,
                      color: severityColor,
                      icon: Icons.warning_amber_outlined,
                    ),
                    _Pill(
                      text: lokasi,
                      color: Colors.indigo,
                      icon: Icons.place_outlined,
                    ),
                    _Pill(
                      text: tanggal,
                      color: Colors.grey[700]!,
                      icon: Icons.schedule,
                    ),
                    _Pill(
                      text: userName,
                      color: Colors.blueGrey,
                      icon: Icons.person_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ dropdown status admin (hanya ini yang bisa diubah)
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentStatus,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(12),
                            iconEnabledColor: statusColor,
                            items: statusItems
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null && v != status) {
                                onStatusChanged(v);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  const _Thumb({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        height: 72,
        color: Colors.indigo[50],
        child: (url == null || url!.isEmpty)
            ? const Icon(Icons.image_outlined, color: Colors.grey)
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, color: Colors.grey),
                loadingBuilder: (context, child, prog) {
                  if (prog == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _Pill({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
