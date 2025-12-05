import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;
  final Timestamp createdAt;
  final String? photoURL;
  final String? provider;
  final Timestamp? emailVerifiedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
    this.photoURL,
    this.provider,
    this.emailVerifiedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'emailVerified': emailVerified,
      'createdAt': createdAt,
      'photoURL': photoURL,
      'provider': provider,
      'emailVerifiedAt': emailVerifiedAt,
      'updatedAt': Timestamp.now(),
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      emailVerified: map['emailVerified'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      photoURL: map['photoURL'],
      provider: map['provider'],
      emailVerifiedAt: map['emailVerifiedAt'],
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    bool? emailVerified,
    String? photoURL,
    String? provider,
    Timestamp? emailVerifiedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: $role, emailVerified: $emailVerified, emailVerifiedAt: $emailVerifiedAt)';
  }
}
