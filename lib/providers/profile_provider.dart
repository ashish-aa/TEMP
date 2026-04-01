import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Map<String, dynamic> profileData = {};

  /// LOAD PROFILE
  Future<void> loadProfile(String uid) async {
    final doc = await _dbService.getUserProfile(uid);

    if (doc != null) {
      profileData = doc;
      notifyListeners();
    }
  }

  /// SAVE PROFILE
  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    await _dbService.saveUserProfile(uid, data);
    profileData = data;
    notifyListeners();
  }

  /// ❌ STORAGE REMOVED
  Future<void> uploadResumeDummy() async {
    // Not using Firebase Storage
  }
}
