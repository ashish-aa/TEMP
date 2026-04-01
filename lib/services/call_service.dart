import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_secrets.dart';

class CallService {
  RtcEngine? _engine;
  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  Function? onStateChanged;

  Future<void> initAgora() async {
    if (!AppSecrets.hasValidAgoraAppId) {
      throw Exception(
        "Agora App ID not configured. Update lib/config/app_secrets.dart",
      );
    }

    // Permissions check
    await [Permission.camera, Permission.microphone].request();

    // Step 1: Initialize Agora Engine properly
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: AppSecrets.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Step 3: HANDLE REMOTE USER (onUserJoined)
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print("Local user joined: ${connection.localUid}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("Remote user joined: $remoteUid");
          _remoteUid = remoteUid;
          onStateChanged?.call();
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              print("Remote user offline: $remoteUid");
              if (_remoteUid == remoteUid) {
                _remoteUid = null;
              }
              onStateChanged?.call();
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print("Left channel");
          _remoteUid = null;
          onStateChanged?.call();
        },
      ),
    );

    await _engine!.enableVideo();
    await _engine!.startPreview();

    // Audio Fix
    await _engine!.enableAudio();
    await _engine!.muteLocalAudioStream(false);
  }

  Future<void> joinChannel(String channelName, int uid, {String? token}) async {
    if (_engine == null) await initAgora();

    print("Joining channel: $channelName with UID: $uid");

    // Step 2: JOIN CHANNEL (Publish tracks explicitly)
    await _engine!.joinChannel(
      token: token ?? _safeToken(),
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  String _safeToken() {
    const placeholder = 'YOUR_AGORA_TEMP_TOKEN';
    if (AppSecrets.agoraTempToken.isEmpty ||
        AppSecrets.agoraTempToken == placeholder) {
      return '';
    }
    return AppSecrets.agoraTempToken;
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    _remoteUid = null;
  }

  RtcEngine? get engine => _engine;

  void toggleMic(bool enabled) {
    _engine?.muteLocalAudioStream(!enabled);
  }

  void toggleCamera(bool enabled) {
    _engine?.muteLocalVideoStream(!enabled);
  }
}
