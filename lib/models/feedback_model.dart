import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String interviewId;

  /// Overall score (0–100)
  final double score;

  /// Detailed ratings (UI stars साठी)
  final double technicalRating;
  final double communicationRating;
  final double problemSolvingRating;
  final double cultureFitRating;

  final List<String> communicationTips;
  final List<String> technicalTips;
  final String overallComment;

  final String decision; // Strong Yes, Yes, Maybe, No

  final DateTime timestamp;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.interviewId,
    required this.score,
    required this.technicalRating,
    required this.communicationRating,
    required this.problemSolvingRating,
    required this.cultureFitRating,
    required this.communicationTips,
    required this.technicalTips,
    required this.overallComment,
    required this.decision,
    required this.timestamp,
  });

  /// 🔄 Firestore → Model
  factory FeedbackModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FeedbackModel(
      id: documentId,
      userId: map['userId'] ?? '',
      interviewId: map['interviewId'] ?? '',
      score: (map['score'] ?? 0).toDouble(),

      technicalRating: (map['technicalRating'] ?? 0).toDouble(),
      communicationRating: (map['communicationRating'] ?? 0).toDouble(),
      problemSolvingRating: (map['problemSolvingRating'] ?? 0).toDouble(),
      cultureFitRating: (map['cultureFitRating'] ?? 0).toDouble(),

      communicationTips: List<String>.from(map['communicationTips'] ?? []),
      technicalTips: List<String>.from(map['technicalTips'] ?? []),

      overallComment: map['overallComment'] ?? '',
      decision: map['decision'] ?? 'Maybe',

      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'interviewId': interviewId,
      'score': score,

      'technicalRating': technicalRating,
      'communicationRating': communicationRating,
      'problemSolvingRating': problemSolvingRating,
      'cultureFitRating': cultureFitRating,

      'communicationTips': communicationTips,
      'technicalTips': technicalTips,

      'overallComment': overallComment,
      'decision': decision,

      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// 🎯 Helper (UI साठी overall rating out of 5)
  double get overallOutOf5 => score > 5 ? score / 20 : score;

  /// 🎨 Decision color (UI badge)
  String get decisionLabel => decision;
}
