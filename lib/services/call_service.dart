import '../config/app_secrets.dart';

class CallService {
  String buildRoomId(String? rawRoomId) {
    final normalized = (rawRoomId ?? '').trim();
    if (normalized.isNotEmpty) return normalized;
    return 'interview_${DateTime.now().millisecondsSinceEpoch}';
  }

  String buildUserId({required bool isInterviewer, required String firebaseUid}) {
    final rolePrefix = isInterviewer ? 'interviewer' : 'candidate';
    return '${rolePrefix}_$firebaseUid';
  }

  String buildUserName({required bool isInterviewer}) {
    return isInterviewer ? 'Interviewer' : 'Candidate';
  }

  bool get isConfigured => AppSecrets.hasValidZegoConfig;
}
