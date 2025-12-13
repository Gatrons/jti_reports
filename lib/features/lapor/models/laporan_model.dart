import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanModel {
  final String id;
  final String jenisKerusakan;
  final String? deskripsi;
  final String? tingkatKeparahan;
  final String? lokasi;
  final List<String> mediaPaths;
  final String status;
  final String? userId;
  final DateTime? timestamp;
  final DateTime? updatedAt;

  LaporanModel({
    required this.id,
    required this.jenisKerusakan,
    this.deskripsi,
    this.tingkatKeparahan,
    this.lokasi,
    this.mediaPaths = const [],
    this.status = 'Diajukan',
    this.userId,
    this.timestamp,
    this.updatedAt,
  });

  factory LaporanModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LaporanModel(
      id: doc.id,
      jenisKerusakan: (data['jenis_kerusakan'] ?? '') as String,
      deskripsi: data['deskripsi'] as String?,
      tingkatKeparahan: data['tingkat_keparahan'] as String?,
      lokasi: data['lokasi'] as String?,
      mediaPaths: ((data['media_paths'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList(),
      status: (data['status'] ?? 'Diajukan') as String,
      userId: data['user_id'] as String?,
      timestamp: data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] is Timestamp ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jenis_kerusakan': jenisKerusakan,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (tingkatKeparahan != null) 'tingkat_keparahan': tingkatKeparahan,
      if (lokasi != null) 'lokasi': lokasi,
      'media_paths': mediaPaths,
      'status': status,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  LaporanModel copyWith({
    String? jenisKerusakan,
    String? deskripsi,
    String? tingkatKeparahan,
    String? lokasi,
    List<String>? mediaPaths,
    String? status,
    String? userId,
    DateTime? timestamp,
    DateTime? updatedAt,
  }) {
    return LaporanModel(
      id: id,
      jenisKerusakan: jenisKerusakan ?? this.jenisKerusakan,
      deskripsi: deskripsi ?? this.deskripsi,
      tingkatKeparahan: tingkatKeparahan ?? this.tingkatKeparahan,
      lokasi: lokasi ?? this.lokasi,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}