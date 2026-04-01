import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/meeting_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingScreen extends StatefulWidget {
  final String? roomId;
  final bool isJoin;

  const MeetingScreen({super.key, this.roomId, this.isJoin = false});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final MeetingService _meetingService = MeetingService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  String? currentRoomId;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _startSession();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startSession() async {
    // Request permissions
    var status = await [Permission.camera, Permission.microphone].request();
    if (status[Permission.camera]!.isDenied ||
        status[Permission.microphone]!.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera and Microphone permissions are required"),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    await _meetingService.openUserMedia(_localRenderer, _remoteRenderer);

    if (widget.isJoin && widget.roomId != null) {
      await _meetingService.joinRoom(widget.roomId!, _remoteRenderer);
      setState(() {
        currentRoomId = widget.roomId;
      });
    } else {
      String id = await _meetingService.createRoom(_remoteRenderer);
      setState(() {
        currentRoomId = id;
      });
      // In a real app, you'd share this ID with the interviewer/candidate
      print("Room ID created: $id");
    }
  }

  @override
  void dispose() {
    _meetingService.hangUp(_localRenderer, roomId: currentRoomId);
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
    });
    _meetingService.localStream?.getAudioTracks().forEach((track) {
      track.enabled = _isMicOn;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    _meetingService.localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isCameraOn;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Recording metadata is not configured yet. Add cloud recording to enable this.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF111827);
    const surfaceColor = Color(0xFF1F2937);
    const primaryBlue = Color(0xFF2563EB);
    const dangerRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "IH",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Meeting Room",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ElevatedButton.icon(
              onPressed: () async {
                await _meetingService.hangUp(
                  _localRenderer,
                  roomId: currentRoomId,
                );
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.call_end, size: 18),
              label: const Text("Leave"),
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (currentRoomId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Room ID: $currentRoomId",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          if (currentRoomId != null)
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: currentRoomId!));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Room ID copied")),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
              label: const Text(
                "Copy",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  // Main Video (Remote)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RTCVideoView(_remoteRenderer),
                          if (_remoteRenderer.srcObject == null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Waiting for other participant...",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          Positioned(
                            bottom: 24,
                            child: Text(
                              _isCameraOn
                                  ? "Your Camera is ON"
                                  : "Your Camera is OFF",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // PiP Video (Local)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isCameraOn
                            ? RTCVideoView(_localRenderer, mirror: true)
                            : const Center(
                                child: Icon(
                                  Icons.videocam_off,
                                  color: Colors.white24,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlCircle(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  isActive: _isMicOn,
                  onTap: _toggleMic,
                ),
                const SizedBox(width: 16),
                _ControlCircle(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  isActive: _isCameraOn,
                  onTap: _toggleCamera,
                ),
                const SizedBox(width: 16),
                _ControlCircle(
                  icon: Icons.fiber_manual_record,
                  isActive: _isRecording,
                  color: _isRecording
                      ? dangerRed
                      : Colors.white.withOpacity(0.1),
                  onTap: _toggleRecording,
                ),
                const SizedBox(width: 16),
                _ControlCircle(
                  icon: Icons.chat_bubble_outline,
                  isActive: false,
                  onTap: () {
                    // Chat logic
                  },
                ),
                const SizedBox(width: 16),
                _ControlCircle(
                  icon: Icons.more_horiz,
                  isActive: false,
                  onTap: () {
                    // More options
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ControlCircle({
    required IconData icon,
    required bool isActive,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color:
              color ??
              (isActive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1)),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
