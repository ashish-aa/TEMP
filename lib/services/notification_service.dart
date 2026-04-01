import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_model.dart';

class InterviewNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// STREAM INTERVIEWS
  Stream<List<InterviewModel>> streamInterviews(String userId) {
    try {
      return _db
          .collection('interviews')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) {
              return InterviewModel.fromMap(doc.data(), doc.id);
            }).toList(),
          );
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// ADD INTERVIEW (SAFE ID)
  Future<void> addInterview(InterviewModel interview) async {
    try {
      final docRef = _db.collection('interviews').doc();

      await docRef.set({
        ...interview.toMap(),
        'id': docRef.id,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add interview");
    }
  }

  /// UPDATE STATUS
  Future<void> updateInterviewStatus(String id, String status) async {
    try {
      await _db.collection('interviews').doc(id).update({'status': status});
    } catch (_) {
      throw Exception("Update failed");
    }
  }

  /// DELETE INTERVIEW
  Future<void> deleteInterview(String id) async {
    try {
      await _db.collection('interviews').doc(id).delete();
    } catch (_) {
      throw Exception("Delete failed");
    }
  }
}
