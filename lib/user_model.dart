class UserModel {
  final String uid;
  final String email;
  final String role;
  final String fullName;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.fullName,
  });

  /// 🔥 FIX FOR ERROR
  String get name => fullName;

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'candidate',
      fullName: data['fullName'] ?? '',
    );
  }
}
