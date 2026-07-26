import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'Student' or 'Company'
  final String phone;
  final String photoUrl;
  final String provider; // 'email' or 'google'
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.photoUrl = '',
    this.provider = 'email',
    required this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedCreatedAt;
    if (map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedLastLoginAt;
    if (map['lastLoginAt'] is Timestamp) {
      parsedLastLoginAt = (map['lastLoginAt'] as Timestamp).toDate();
    } else if (map['lastLoginAt'] is String) {
      parsedLastLoginAt = DateTime.tryParse(map['lastLoginAt']);
    }

    final photo = map['profilePhoto'] ?? map['photoUrl'] ?? '';

    return UserModel(
      uid: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Student',
      phone: map['phone'] ?? '',
      photoUrl: photo is String ? photo : '',
      provider: map['provider'] ?? 'email',
      createdAt: parsedCreatedAt,
      lastLoginAt: parsedLastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'profilePhoto': photoUrl,
      'provider': provider,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
