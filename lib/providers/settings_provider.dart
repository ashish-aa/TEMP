import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = "isDarkMode";
  static const String _pushKey = "pushNotifications";
  static const String _emailKey = "emailNotifications";
  static const String _languageKey = "language";

  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _language = 'English';

  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  String get language => _language;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadFromPrefs();
  }

  /// 🔄 Load all settings
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _pushNotifications = prefs.getBool(_pushKey) ?? true;
    _emailNotifications = prefs.getBool(_emailKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'English';

    _isLoading = false;
    notifyListeners();
  }

  /// 🌙 Dark Mode
  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  /// 🔔 Push Notifications
  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
    notifyListeners();
  }

  /// 📧 Email Notifications
  Future<void> toggleEmailNotifications(bool value) async {
    _emailNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailKey, value);
    notifyListeners();
  }

  /// 🌍 Language
  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
    notifyListeners();
  }

  /// 🔄 Reset All Settings
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isDarkMode = false;
    _pushNotifications = true;
    _emailNotifications = false;
    _language = 'English';

    notifyListeners();
  }
}
