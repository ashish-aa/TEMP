import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class RecordingService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    // Use front camera if available
    CameraDescription? frontCamera;
    try {
      frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } catch (e) {
      frontCamera = _cameras!.first;
    }

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller!.initialize();
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isRecordingVideo) return;
    await _controller!.startVideoRecording();
  }

  Future<XFile?> stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo)
      return null;
    return await _controller!.stopVideoRecording();
  }

  Future<String> saveRecording(XFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final String interviewDir = p.join(directory.path, 'interviews');

    final dir = Directory(interviewDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final String fileName =
        'interview_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final String path = p.join(interviewDir, fileName);

    // Copy file to permanent storage
    await File(file.path).copy(path);
    return path;
  }

  Future<List<File>> getRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final String interviewDir = p.join(directory.path, 'interviews');
    final dir = Directory(interviewDir);

    if (!await dir.exists()) return [];

    return dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.mp4'))
        .toList();
  }

  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}
