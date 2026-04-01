import 'package:flutter/material.dart';

class InterviewProvider extends ChangeNotifier {
  bool isLoading = false;

  List<Map<String, dynamic>> recordings = [];

  /// 🔥 ADD RECORDING (LOCAL ONLY)
  Future<void> addRecording(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();

      // ✅ NO FIREBASE STORAGE
      recordings.add(data);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Recording error: $e");
    }
  }

  /// 🔥 GET RECORDINGS
  List<Map<String, dynamic>> get allRecordings => recordings;
}
