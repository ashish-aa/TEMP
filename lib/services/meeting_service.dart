import 'call_service.dart';

/// Compatibility shim.
///
/// The project now uses Agora as the only real-time stack.
/// This class exists to reduce merge friction with branches still importing
/// `MeetingService` from older code paths.
class MeetingService {
  final CallService _callService = CallService();

  CallService get callService => _callService;

  Future<void> init() async {
    await _callService.initAgora();
  }

  Future<void> dispose() async {
    await _callService.leaveChannel();
  }
}
