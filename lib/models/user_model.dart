import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { candidate, interviewer, admin }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String profileImage;
  final String phone;
  final String location;
  final String headline;
  final String summary;
  final bool isProfileComplete;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.profileImage,
    this.phone = '',
    this.location = '',
    this.headline = '',
    this.summary = '',
    this.isProfileComplete = false,
    required this.createdAt,
  });

  /// 👤 Full name helper
  String get fullName => "$firstName $lastName";

  /// 🔄 Firestore → Model
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: _roleFromString(map['role']),
      profileImage: map['profileImage'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      headline: map['headline'] ?? '',
      summary: map['summary'] ?? '',
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'profileImage': profileImage,
      'phone': phone,
      'location': location,
      'headline': headline,
      'summary': summary,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 🔁 String → Enum
  static UserRole _roleFromString(String? role) {
    switch (role) {
      case 'interviewer':
        return UserRole.interviewer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.candidate;
    }
  }

  /// 🎯 Role check helpers
  bool get isInterviewer => role == UserRole.interviewer;
  bool get isCandidate => role == UserRole.candidate;
  bool get isAdmin => role == UserRole.admin;
}
