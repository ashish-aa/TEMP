import 'call_service.dart';

class MeetingService {
  final CallService _callService = CallService();

  CallService get callService => _callService;

  String createRoomId() => 'room_${DateTime.now().millisecondsSinceEpoch}';
}
