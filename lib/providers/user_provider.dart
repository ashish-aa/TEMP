import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  /// 👤 Set user
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// 🔄 Update user (profile edit साठी)
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  /// 🔄 Loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 🚪 Clear on logout
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
