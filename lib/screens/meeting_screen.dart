import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/meeting_service.dart';

class MeetingScreen extends StatefulWidget {
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
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final MeetingService _meetingService = MeetingService();

  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isLoading = true;
  late final String _channelName;

  @override
  void initState() {
    super.initState();
    _channelName = (widget.roomId ?? '').trim().isNotEmpty
        ? widget.roomId!.trim()
        : _meetingService.createRoomId();
    _startSession();
  }

  Future<void> _startSession() async {
    try {
      await _meetingService.initialize(onStateChanged: () {
        if (mounted) setState(() {});
      });
      await _meetingService.joinRoom(
        roomId: _channelName,
        isInterviewer: widget.isInterviewer,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _meetingService.leaveRoom();
    super.dispose();
  }

  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    _meetingService.callService.toggleMic(_isMicOn);
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    _meetingService.callService.toggleCamera(_isCameraOn);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryBlue = Color(0xFF2563EB);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    final remoteUid = _meetingService.callService.remoteUid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        title: const Text('Meeting Room'),
        actions: [
          IconButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _channelName));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room ID copied to clipboard')),
                );
              }
            },
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy room ID',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: remoteUid == null
                ? _buildWaitingView(primaryBlue)
                : AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _meetingService.callService.engine!,
                      canvas: VideoCanvas(uid: remoteUid),
                      connection: RtcConnection(channelId: _channelName),
                    ),
                  ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Room ID: $_channelName',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          Positioned(
            top: 74,
            right: 16,
            child: SizedBox(
              width: 120,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _isCameraOn
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _meetingService.callService.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF1F2937),
                        child: const Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _control(_isMicOn ? Icons.mic : Icons.mic_off, _toggleMic),
                const SizedBox(width: 16),
                _control(
                  _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  _toggleCamera,
                ),
                const SizedBox(width: 16),
                _control(Icons.call_end, () async {
                  await _meetingService.leaveRoom();
                  if (mounted) Navigator.pop(context);
                }, danger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _control(IconData icon, VoidCallback onTap, {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: danger ? Colors.red : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildWaitingView(Color primaryBlue) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: primaryBlue.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white54, size: 54),
          ),
          const SizedBox(height: 20),
          const Text(
            'Waiting for participant to join...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
