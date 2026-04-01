import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordingStatus { processing, ready, failed }

class RecordingModel {
  final String id;
  final String userId;

  /// Firebase Storage URL
  final String videoUrl;

  /// Local path (optional)
  final String localPath;

  final String title;
  final DateTime timestamp;

  /// Duration in seconds
  final int duration;

  /// Thumbnail image URL
  final String thumbnailUrl;

  final RecordingStatus status;

  RecordingModel({
    required this.id,
    required this.userId,
    required this.videoUrl,
    required this.localPath,
    required this.title,
    required this.timestamp,
    required this.duration,
    required this.thumbnailUrl,
    required this.status,
  });

  /// 🔄 Firestore → Model
  factory RecordingModel.fromMap(Map<String, dynamic> data, String documentId) {
    return RecordingModel(
      id: documentId,
      userId: data['userId'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      localPath: data['localPath'] ?? '',
      title: data['title'] ?? 'Untitled Recording',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: data['duration'] ?? 0,
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      status: _statusFromString(data['status']),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'videoUrl': videoUrl,
      'localPath': localPath,
      'title': title,
      'timestamp': Timestamp.fromDate(timestamp),
      'duration': duration,
      'thumbnailUrl': thumbnailUrl,
      'status': status.name,
    };
  }

  /// 🔁 String → Enum
  static RecordingStatus _statusFromString(String? status) {
    switch (status) {
      case 'ready':
        return RecordingStatus.ready;
      case 'failed':
        return RecordingStatus.failed;
      default:
        return RecordingStatus.processing;
    }
  }

  /// 🎥 UI helper → duration format
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  /// 🎨 Status label
  String get statusLabel {
    switch (status) {
      case RecordingStatus.ready:
        return "Ready";
      case RecordingStatus.failed:
        return "Failed";
      default:
        return "Processing";
    }
  }
}
