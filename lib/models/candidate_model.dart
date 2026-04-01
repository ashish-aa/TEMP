import 'package:cloud_firestore/cloud_firestore.dart';

enum CandidateStatus { pending, interview, hired, rejected }

class CandidateModel {
  final String id;
  final String name;
  final String email;
  final String position;
  final double rating;
  final CandidateStatus status;
  final int interviewsCount;
  final DateTime createdAt;

  CandidateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.position,
    required this.rating,
    required this.status,
    required this.interviewsCount,
    required this.createdAt,
  });

  /// 🔄 Firestore → Model
  factory CandidateModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CandidateModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      position: map['position'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      status: _statusFromString(map['status']),
      interviewsCount: map['interviewsCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'position': position,
      'rating': rating,
      'status': status.name, // enum → string
      'interviewsCount': interviewsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 🔁 String → Enum
  static CandidateStatus _statusFromString(String? status) {
    switch (status) {
      case 'interview':
        return CandidateStatus.interview;
      case 'hired':
        return CandidateStatus.hired;
      case 'rejected':
        return CandidateStatus.rejected;
      default:
        return CandidateStatus.pending;
    }
  }

  /// 🎨 UI helper (badge color)
  String get statusLabel {
    switch (status) {
      case CandidateStatus.hired:
        return "Hired";
      case CandidateStatus.interview:
        return "Interview";
      case CandidateStatus.rejected:
        return "Rejected";
      default:
        return "Pending";
    }
  }
}
