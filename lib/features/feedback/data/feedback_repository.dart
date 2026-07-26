import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/feedback_model.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _feedbacksRef =>
      _firestore.collection('feedbacks');

  Stream<List<FeedbackModel>> getFeedbacksStream({
    String? category,
    String? role,
    String? status,
    String sortBy = 'Newest',
  }) {
    Query<Map<String, dynamic>> query = _feedbacksRef;

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (role != null && role.isNotEmpty && role != 'All') {
      query = query.where('role', isEqualTo: role);
    }
    if (status != null && status.isNotEmpty && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }

    switch (sortBy) {
      case 'Oldest':
        query = query.orderBy('createdAt', descending: false);
        break;
      case 'Highest Rating':
        query = query.orderBy('rating', descending: true);
        break;
      case 'Lowest Rating':
        query = query.orderBy('rating', descending: false);
        break;
      case 'Newest':
      default:
        query = query.orderBy('createdAt', descending: true);
        break;
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String> createFeedback(FeedbackModel feedback) async {
    try {
      final docRef = await _feedbacksRef.add(feedback.toMap());
      await docRef.update({'feedbackId': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to submit feedback: ${e.toString()}');
    }
  }

  Future<void> updateFeedback(FeedbackModel feedback) async {
    try {
      final map = feedback.toMap();
      map['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _feedbacksRef.doc(feedback.feedbackId).update(map);
    } catch (e) {
      throw Exception('Failed to update feedback: ${e.toString()}');
    }
  }

  Future<void> deleteFeedback(String feedbackId, String currentUserId) async {
    try {
      final doc = await _feedbacksRef.doc(feedbackId).get();
      if (!doc.exists) {
        throw Exception('Feedback not found');
      }

      final data = doc.data();
      if (data != null && data['submittedBy'] != currentUserId) {
        throw Exception('Permission denied: You can only delete your own feedback.');
      }

      await _feedbacksRef.doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: ${e.toString()}');
    }
  }

  Future<FeedbackModel?> getFeedbackById(String feedbackId) async {
    try {
      final doc = await _feedbacksRef.doc(feedbackId).get();
      if (doc.exists && doc.data() != null) {
        return FeedbackModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch feedback details: ${e.toString()}');
    }
  }

  Future<List<FeedbackModel>> searchFeedbacks(String queryText) async {
    try {
      final snapshot = await _feedbacksRef.get();
      final all = snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
          .toList();

      if (queryText.trim().isEmpty) return all;

      final lowerQuery = queryText.toLowerCase().trim();
      return all.where((item) {
        final titleMatch = item.title.toLowerCase().contains(lowerQuery);
        final categoryMatch = item.category.toLowerCase().contains(lowerQuery);
        final userMatch = item.submittedByName.toLowerCase().contains(lowerQuery);
        final descMatch = item.description.toLowerCase().contains(lowerQuery);
        return titleMatch || categoryMatch || userMatch || descMatch;
      }).toList();
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }
}
