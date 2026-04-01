import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _service = ConnectivityService();

  bool _isOnline = true;
  bool _isChecking = false;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;

  StreamSubscription? _subscription;

  ConnectivityProvider() {
    _init();
  }

  void _init() async {
    _isChecking = true;
    notifyListeners();

    _isOnline = await _service.hasInternet;

    _subscription = _service.connectivityStream.listen((result) async {
      _isOnline = await _service.hasInternet;
      notifyListeners();
    });

    _isChecking = false;
    notifyListeners();
  }

  Future<void> checkConnection() async {
    _isChecking = true;
    notifyListeners();
    _isOnline = await _service.hasInternet;
    _isChecking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
