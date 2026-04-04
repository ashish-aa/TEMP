import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Login with Email & Password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.reload();

    final refreshed = _auth.currentUser;
    if (refreshed != null && !refreshed.emailVerified) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Verify your email before signing in.',
      );
    }

    return credential;
  }

  // Signup with Email & Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create user profile in Firestore
    if (credential.user != null) {
      final userRole = _roleFromString(role);
      await _createUserProfile(
        UserModel(
          id: credential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: userRole,
          profileImage: '',
          createdAt: DateTime.now(),
        ),
      );

      await credential.user!.sendEmailVerification();
    }
    return credential;
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle({
    required UserRole role,
  }) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    // Check if user profile already exists
    DocumentSnapshot doc = await _db
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    if (!doc.exists) {
      final names = (userCredential.user!.displayName ?? 'User').split(' ');
      final firstName = names.isNotEmpty ? names[0] : 'User';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      await _createUserProfile(
        UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          firstName: firstName,
          lastName: lastName,
          role: role,
          profileImage: userCredential.user!.photoURL ?? '',
          createdAt: DateTime.now(),
        ),
      );
    }

    return userCredential;
  }

  // Create User Profile in Firestore
  Future<void> _createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Get User Model
  Future<UserModel?> getUserModel(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  UserRole _roleFromString(String? role) {
    switch (role) {
      case 'interviewer':
        return UserRole.interviewer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.candidate;
    }
  }
}
