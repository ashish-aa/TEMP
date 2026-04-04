import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/call_service.dart';

class MockInterviewScreen extends StatelessWidget {
  final String? roomId;
  final bool isInterviewer;

  const MockInterviewScreen({
    super.key,
    this.roomId,
    required this.isInterviewer,
  });

  @override
  Widget build(BuildContext context) {
    final callService = CallService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (!AppSecrets.hasValidZegoConfig) {
      return _errorScaffold(
        'ZEGOCLOUD credentials are missing. Update lib/config/app_secrets.dart.',
      );
    }

    if (uid == null) {
      return _errorScaffold('You must be signed in to join the interview call.');
    }

    final callID = callService.buildRoomId(roomId);
    final userID = callService.buildUserId(
      isInterviewer: isInterviewer,
      firebaseUid: uid,
    );
    final userName = callService.buildUserName(isInterviewer: isInterviewer);

    final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
      ..turnOnCameraWhenJoining = true
      ..turnOnMicrophoneWhenJoining = true;

    return Scaffold(
      appBar: AppBar(
        title: Text(isInterviewer ? 'Interviewer View' : 'Candidate View'),
      ),
      body: ZegoUIKitPrebuiltCall(
        appID: AppSecrets.zegoAppId,
        appSign: AppSecrets.zegoAppSign,
        userID: userID,
        userName: userName,
        callID: callID,
        config: config,
      ),
    );
  }

  Widget _errorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interview Call')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
