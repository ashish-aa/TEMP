import 'dart:math';

import 'call_service.dart';

/// Agora-backed meeting facade used by legacy screens.
class MeetingService {
  final CallService _callService = CallService();

  CallService get callService => _callService;

  Future<void> initialize({required void Function() onStateChanged}) async {
    _callService.onStateChanged = onStateChanged;
    await _callService.initAgora();
  }

  Future<void> joinRoom({
    required String roomId,
    required bool isInterviewer,
  }) async {
    final normalized = roomId.trim().isEmpty ? _fallbackRoomId() : roomId.trim();
    final uid = isInterviewer ? 1 : 2;
    await _callService.joinChannel(normalized, uid);
  }

  Future<void> leaveRoom() => _callService.leaveChannel();

  String createRoomId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final randomPart = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'room_${millis}_$randomPart';
  }

  String _fallbackRoomId() => 'interview_${DateTime.now().millisecondsSinceEpoch}';
}
