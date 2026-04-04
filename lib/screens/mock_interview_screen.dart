import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/call_service.dart';

class MockInterviewScreen extends StatefulWidget {
  final String? roomId;
  final bool isInterviewer;

  const MockInterviewScreen({
    super.key,
    this.roomId,
    required this.isInterviewer,
  });

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final CallService _callService = CallService();
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAgora();
  }

  Future<void> _setupAgora() async {
    // 1. Hook up the UI rebuild callback
    _callService.onStateChanged = () {
      if (mounted) setState(() {});
    };

    try {
      // 2. Initialize the engine (Step 1 from requirements)
      await _callService.initAgora();

      // 3. Assign UNIQUE UIDs (Step 2 from requirements)
      // Interviewer = 1, Candidate = 2
      final int uid = widget.isInterviewer ? 1 : 2;

      // Use roomId from Firestore as channelId
      final String channelName = widget.roomId ?? "interview_default";

      // 4. Join the channel (Step 2 logic)
      await _callService.joinChannel(channelName, uid);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Agora Setup Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start video: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _callService.leaveChannel();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      _isMicOn = !_isMicOn;
      _callService.toggleMic(_isMicOn);
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
      _callService.toggleCamera(_isCameraOn);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF111827);
    const primaryBlue = Color(0xFF2563EB);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    final remoteUid = _callService.remoteUid;
    final channelName = widget.roomId ?? "interview_default";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.isInterviewer ? "Hiring Manager View" : "Candidate View",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.call_end, size: 18),
              label: const Text("Leave"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. REMOTE VIDEO (Full Screen) - Step 4 logic
          Positioned.fill(
            child: remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _callService.engine!,
                      canvas: VideoCanvas(uid: remoteUid),
                      connection: RtcConnection(channelId: channelName),
                    ),
                  )
                : _buildPlaceholderView(primaryBlue),
          ),

          // 2. LOCAL VIDEO (PiP) - Step 4 logic
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isCameraOn
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _callService.engine!,
                          canvas: const VideoCanvas(
                            uid: 0,
                          ), // uid 0 renders local video
                        ),
                      )
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

          // 3. CONTROLS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlBtn(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  onTap: _toggleMic,
                  isActive: _isMicOn,
                ),
                const SizedBox(width: 20),
                _buildControlBtn(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  onTap: _toggleCamera,
                  isActive: _isCameraOn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderView(Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text(
            "Waiting for other participant...",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
