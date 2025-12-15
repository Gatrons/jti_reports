import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jti_reports/core/widgets/appbar/main_app_bar_admin.dart';

class AdminHomePage extends StatefulWidget {
  final void Function(int index) onTabChange;

  const AdminHomePage({super.key, required this.onTabChange});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // ====== Helpers ======
  String _monthLabel(DateTime m) {
    return DateFormat('MMMM yyyy', 'id_ID').format(m);
  }

  DateTime _monthStart(DateTime m) => DateTime(m.year, m.month, 1);
  DateTime _monthEndExclusive(DateTime m) => DateTime(m.year, m.month + 1, 1);

  DateTime _asDate(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF388E3C);
      case 'diproses':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFFD32F2F);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_outline;
      case 'diproses':
        return Icons.hourglass_top;
      default:
        return Icons.error_outline;
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
    }
    return lokasiValue.toString();
  }

  List<DateTime> _lastNMonths(int n) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, 1);
    return List.generate(n, (i) {
      final d = DateTime(base.year, base.month - i, 1);
      return d;
    });
  }

  Future<void> _pickMonth() async {
    final months = _lastNMonths(12);

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: months.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final m = months[i];
              final isSelected =
                  m.year == _selectedMonth.year &&
                  m.month == _selectedMonth.month;
              return ListTile(
                title: Text(_monthLabel(m)),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.indigo)
                    : null,
                onTap: () => Navigator.pop(context, m),
              );
            },
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  // ====== Firestore stream (ambil semua, filter di client biar aman dari index) ======
  Stream<QuerySnapshot<Map<String, dynamic>>> _reportsStream() {
    return FirebaseFirestore.instance.collection('reports').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBarAdmin(title: 'Beranda'),
      backgroundColor: Colors.indigo[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _reportsStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Gagal memuat data: ${snap.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final docs = snap.data?.docs ?? [];

            // Filter bulan (client-side)
            final start = _monthStart(_selectedMonth);
            final endEx = _monthEndExclusive(_selectedMonth);

            final monthDocs = docs.where((d) {
              final data = d.data();
              final dt = _asDate(data['timestamp']);
              return dt.isAfter(
                    start.subtract(const Duration(milliseconds: 1)),
                  ) &&
                  dt.isBefore(endEx);
            }).toList();

            // Sort newest
            monthDocs.sort((a, b) {
              final ta = _asDate(a.data()['timestamp']);
              final tb = _asDate(b.data()['timestamp']);
              return tb.compareTo(ta);
            });

            // Count per status
            int diajukan = 0, diproses = 0, selesai = 0;
            for (final d in monthDocs) {
              final status = (d.data()['status'] ?? 'Diajukan')
                  .toString()
                  .toLowerCase();
              if (status == 'selesai')
                selesai++;
              else if (status == 'diproses')
                diproses++;
              else
                diajukan++;
            }

            // recent list (3 data)
            final recent = monthDocs.take(3).toList();

            return ListView(
              children: [
                _buildHeaderWelcome(),
                const SizedBox(height: 20),

                // ===== Status per Bulan (dinamis) =====
                _buildStatusPerBulanSection(
                  monthLabel: _monthLabel(_selectedMonth),
                  onPickMonth: _pickMonth,
                  diajukan: diajukan,
                  diproses: diproses,
                  selesai: selesai,
                ),

                const SizedBox(height: 30),

                // ===== Status per Tanggal (list dinamis) =====
                _buildStatusPerTanggalSection(
                  context,
                  monthLabel: _monthLabel(_selectedMonth),
                  recentDocs: recent,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============ HEADER ============
  Widget _buildHeaderWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang, Admin!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pantau status pelaporan fasilitas kampus.',
          style: TextStyle(color: Colors.black.withOpacity(0.6)),
        ),
      ],
    );
  }

  // ============ STATUS PER BULAN ============
  Widget _buildStatusPerBulanSection({
    required String monthLabel,
    required VoidCallback onPickMonth,
    required int diajukan,
    required int diproses,
    required int selesai,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + bulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Pelaporan per Bulan :',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onPickMonth,
                child: _buildMonthChip(monthLabel),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 3 kartu ringkasan (dinamis)
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Diajukan',
                  count: diajukan,
                  gradientColors: const [Color(0xFFFFCDD2), Color(0xFFF8BBD0)],
                  titleColor: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Diproses',
                  count: diproses,
                  gradientColors: const [Color(0xFFFFE0B2), Color(0xFFFFCC80)],
                  titleColor: const Color(0xFFF57C00),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Selesai',
                  count: selesai,
                  gradientColors: const [Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
                  titleColor: const Color(0xFF388E3C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required List<Color> gradientColors,
    required Color titleColor,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ STATUS PER TANGGAL / DAFTAR LAPORAN ============
  Widget _buildStatusPerTanggalSection(
    BuildContext context, {
    required String monthLabel,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> recentDocs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Status Pelaporan per Tanggal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            TextButton(
              onPressed: () => widget.onTabChange(0), // ke tab Riwayat admin
              child: const Text(
                'Lihat semua',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Periode: $monthLabel',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        const SizedBox(height: 10),
        if (recentDocs.isEmpty)
          Text(
            'Belum ada laporan di bulan ini.',
            style: TextStyle(color: Colors.grey[700]),
          )
        else
          Column(
            children: [
              for (final doc in recentDocs) ...[
                _buildReportCardFromDoc(doc),
                const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildReportCardFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final judul = (data['jenis_kerusakan'] ?? 'Laporan').toString();
    final status = (data['status'] ?? 'Diajukan').toString();
    final warna = _statusColor(status);
    final icon = _statusIcon(status);

    final dt = _asDate(data['timestamp']);
    final tanggal = DateFormat('d MMM yyyy', 'id_ID').format(dt);

    // bonus: tampilkan lokasi singkat (optional)
    final lokasi = _lokasiToDisplay(data['lokasi']);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warna.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: warna, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tanggal • $lokasi',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: warna.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: warna,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
