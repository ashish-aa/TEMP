import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_model.dart';
import '../models/recording_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile ---
  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // --- Interviews ---

  // Real-time stream of interviews for a user (either candidate or interviewer)
  Stream<List<InterviewModel>> streamInterviewsForUser(
    String userId, {
    bool isInterviewer = false,
  }) {
    Query query = _db.collection('interviews');

    if (isInterviewer) {
      query = query.where('interviewerId', isEqualTo: userId);
    } else {
      query = query.where('candidateId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return InterviewModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Fetch a specific active interview room
  Future<InterviewModel?> getActiveInterview(
    String userId,
    bool isInterviewer,
  ) async {
    Query query = _db
        .collection('interviews')
        .where(
          isInterviewer ? 'interviewerId' : 'candidateId',
          isEqualTo: userId,
        )
        .where('status', whereIn: ['scheduled', 'ongoing'])
        .limit(1);

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      return InterviewModel.fromMap(
        snap.docs.first.data() as Map<String, dynamic>,
        snap.docs.first.id,
      );
    }
    return null;
  }

  Future<void> updateInterviewStatus(String interviewId, String status) async {
    await _db.collection('interviews').doc(interviewId).update({
      'status': status,
    });
  }

  // --- Candidates (for Interviewers) ---
  Stream<List<Map<String, dynamic>>> streamAllCandidates() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'candidate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // --- Recordings ---
  Stream<List<RecordingModel>> streamUserRecordings(String userId) {
    return _db
        .collection('recordings')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => RecordingModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> addRecordingMetadata(Map<String, dynamic> data) async {
    await _db.collection('recordings').add(data);
  }

  // --- Feedback ---
  Future<void> submitFeedback(
    String interviewId,
    Map<String, dynamic> feedback,
  ) async {
    await _db.collection('interviews').doc(interviewId).update({
      'feedback': feedback,
      'status': 'completed',
    });
  }
}
