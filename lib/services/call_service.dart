import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class CallService {
  // Replace with your actual Agora App ID from Agora Console
  static const String appId = "782ab94df0a24b9686ebe098aa26daa7";

  RtcEngine? _engine;
  int? _remoteUid;
  int? get remoteUid => _remoteUid;

  Function? onStateChanged;

  Future<void> initAgora() async {
    // Permissions check
    await [Permission.camera, Permission.microphone].request();

    // Step 1: Initialize Agora Engine properly
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: appId,
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
      token: token ?? '',
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
