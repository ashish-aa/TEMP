import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of Interivews for a specific user
  Stream<List<InterviewModel>> streamInterviews(String userId) {
    return _db
        .collection('interviews')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InterviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Create a new Interview record
  Future<void> addInterview(InterviewModel interview) async {
    await _db.collection('interviews').add(interview.toMap());
  }

  // Update interview status
  Future<void> updateInterviewStatus(String id, String status) async {
    await _db.collection('interviews').doc(id).update({'status': status});
  }
}
