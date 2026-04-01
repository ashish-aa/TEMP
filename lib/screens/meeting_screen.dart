import 'package:flutter/material.dart';
import 'mock_interview_screen.dart';

/// Compatibility screen.
///
/// Older branches may still navigate to `MeetingScreen`.
/// Internally we redirect to the Agora-backed `MockInterviewScreen` so there
/// is only one call implementation.
class MeetingScreen extends StatelessWidget {
  final String? roomId;
  final bool isJoin;
  final bool isInterviewer;

  const MeetingScreen({
    super.key,
    this.roomId,
    this.isJoin = false,
    this.isInterviewer = false,
  });

  @override
  Widget build(BuildContext context) {
    return MockInterviewScreen(
      roomId: roomId,
      isInterviewer: isInterviewer,
    );
  }
}
