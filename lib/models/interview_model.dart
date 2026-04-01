import 'package:cloud_firestore/cloud_firestore.dart';

enum InterviewStatus { scheduled, pending, ongoing, completed, cancelled }

class InterviewModel {
  final String id;
  final String? roomId;
  final String title;
  final int duration;
  final DateTime startTime;
  final DateTime endTime;
  final InterviewStatus status;
  final String candidateId;
  final String interviewerId;
  final String candidateName;
  final String position;
  final Map<String, dynamic>? feedback;

  InterviewModel({
    required this.id,
    this.roomId,
    required this.title,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.candidateId,
    required this.interviewerId,
    required this.candidateName,
    required this.position,
    this.feedback,
  });

  factory InterviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    final start = (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();
    final end =
        (map['endTime'] as Timestamp?)?.toDate() ??
        start.add(Duration(minutes: map['duration'] ?? 30));

    return InterviewModel(
      id: documentId,
      roomId: map['roomId'],
      title: map['title'] ?? 'Technical Interview',
      duration: map['duration'] ?? 30,
      startTime: start,
      endTime: end,
      status: _statusFromString(map['status']),
      candidateId: map['candidateId'] ?? map['userId'] ?? '',
      interviewerId: map['interviewerId'] ?? '',
      candidateName: map['candidateName'] ?? 'Candidate',
      position: map['position'] ?? 'Software Engineer',
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'title': title,
      'duration': duration,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status.name,
      'candidateId': candidateId,
      'interviewerId': interviewerId,
      'candidateName': candidateName,
      'position': position,
      'feedback': feedback,
    };
  }

  static InterviewStatus _statusFromString(String? status) {
    switch (status) {
      case 'scheduled':
        return InterviewStatus.scheduled;
      case 'ongoing':
        return InterviewStatus.ongoing;
      case 'completed':
        return InterviewStatus.completed;
      case 'cancelled':
        return InterviewStatus.cancelled;
      default:
        return InterviewStatus.pending;
    }
  }

  String get timeRange {
    return "${_formatTime(startTime)} - ${_formatTime(endTime)}";
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final suffix = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:${dt.minute.toString().padLeft(2, '0')} $suffix";
  }
}
