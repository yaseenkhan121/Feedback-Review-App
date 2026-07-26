import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/feedback_model.dart';

class AnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a real-time Stream of FeedbackModel list directly from Cloud Firestore 'feedbacks' collection
  Stream<List<FeedbackModel>> getFeedbackStream() {
    return _firestore
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
