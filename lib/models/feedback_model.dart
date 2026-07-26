import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String feedbackId;
  final String title;
  final String description;
  final double rating;
  final String category;
  final String submittedBy;
  final String submittedByName;
  final String role;
  final String status; // 'Pending', 'Reviewed', 'Resolved'
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackModel({
    required this.feedbackId,
    required this.title,
    required this.description,
    required this.rating,
    required this.category,
    required this.submittedBy,
    required this.submittedByName,
    required this.role,
    this.status = 'Pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return FeedbackModel(
      feedbackId: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      category: map['category'] ?? 'General',
      submittedBy: map['submittedBy'] ?? '',
      submittedByName: map['submittedByName'] ?? 'Anonymous',
      role: map['role'] ?? 'Student',
      status: map['status'] ?? 'Pending',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'feedbackId': feedbackId,
      'title': title,
      'description': description,
      'rating': rating,
      'category': category,
      'submittedBy': submittedBy,
      'submittedByName': submittedByName,
      'role': role,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FeedbackModel copyWith({
    String? feedbackId,
    String? title,
    String? description,
    double? rating,
    String? category,
    String? submittedBy,
    String? submittedByName,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      feedbackId: feedbackId ?? this.feedbackId,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedByName: submittedByName ?? this.submittedByName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
