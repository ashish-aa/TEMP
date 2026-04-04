import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../config/app_secrets.dart';
import '../services/meeting_service.dart';

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
    final meetingService = MeetingService();
    final callService = meetingService.callService;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (!AppSecrets.hasValidZegoConfig) {
      return _buildSetupError(
        'ZEGOCLOUD is not configured. Fill zegoAppId and zegoAppSign in lib/config/app_secrets.dart.',
      );
    }

    if (uid == null) {
      return _buildSetupError('Please sign in before joining a meeting.');
    }

    final callID = callService.buildRoomId(roomId ?? meetingService.createRoomId());
    final userID = callService.buildUserId(
      isInterviewer: isInterviewer,
      firebaseUid: uid,
    );
    final userName = callService.buildUserName(isInterviewer: isInterviewer);

    final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
      ..topMenuBar.isVisible = true
      ..bottomMenuBar.isVisible = true
      ..avatarBuilder = (context, size, user, extraInfo) {
        return CircleAvatar(
          radius: size.width / 2,
          child: Text(user.name.isNotEmpty ? user.name[0] : 'U'),
        );
      };

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: AppSecrets.zegoAppId,
          appSign: AppSecrets.zegoAppSign,
          userID: userID,
          userName: userName,
          callID: callID,
          config: config,
        ),
      ),
    );
  }

  Widget _buildSetupError(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting Setup')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
