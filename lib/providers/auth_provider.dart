import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AppAuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        try {
          _userModel = await _authService.getUserModel(user.uid);
        } catch (e) {
          _error = "Failed to load user data";
        }
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      _userModel = await _authService.getUserModel(_user!.uid);
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithEmail(email, password);
      if (credential.user != null) {
        _userModel = await _authService.getUserModel(credential.user!.uid);
      }
      return true;
    } catch (e) {
      _setError(_getReadableError(e));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setError(null);
    try {
      await _authService.sendPasswordResetEmail(email.trim());
      return true;
    } catch (e) {
      _setError(_getReadableError(e));
      return false;
    }
  }

  bool userMatchesRole(String role) {
    final current = _userModel;
    if (current == null) return false;
    if (role == 'candidate') return current.isCandidate;
    if (role == 'interviewer') return current.isInterviewer;
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      if (credential.user != null) {
        _userModel = await _authService.getUserModel(credential.user!.uid);
      }
      return true;
    } catch (e) {
      _setError(_getReadableError(e));
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    setLoading(true);
    _setError(null);
    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null || cred.user == null) {
        _setError("Google sign-in cancelled.");
        return false;
      }

      _userModel = await _authService.getUserModel(cred.user!.uid);
      return _userModel != null;
    } catch (e) {
      _setError("Google sign-in failed");
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _user = null;
    _userModel = null;
    _isLoading = false;
    notifyListeners();
  }

  String _getReadableError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'invalid-email':
          return 'Invalid email address format.';
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return e.toString();
  }
}
