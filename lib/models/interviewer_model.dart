import 'package:cloud_firestore/cloud_firestore.dart';

enum SkillLevel { expert, advanced, intermediate }

class InterviewerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String company;
  final String department;
  final String position;
  final String bio;
  final List<Specialization> specializations;

  // Stats
  final int completedInterviews;
  final double avgRating;
  final double hireRate;
  final int yearsExperience;

  InterviewerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.company,
    required this.department,
    required this.position,
    required this.bio,
    required this.specializations,
    this.completedInterviews = 0,
    this.avgRating = 0.0,
    this.hireRate = 0.0,
    this.yearsExperience = 0,
  });

  String get fullName => '$firstName $lastName';

  /// 🔄 Firestore → Model
  factory InterviewerModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return InterviewerModel(
      id: documentId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      company: map['company'] ?? '',
      department: map['department'] ?? '',
      position: map['position'] ?? '',
      bio: map['bio'] ?? '',
      specializations: (map['specializations'] as List<dynamic>? ?? [])
          .map((e) => Specialization.fromMap(e))
          .toList(),
      completedInterviews: map['completedInterviews'] ?? 0,
      avgRating: (map['avgRating'] ?? 0).toDouble(),
      hireRate: (map['hireRate'] ?? 0).toDouble(),
      yearsExperience: map['yearsExperience'] ?? 0,
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'department': department,
      'position': position,
      'bio': bio,
      'specializations': specializations.map((e) => e.toMap()).toList(),
      'completedInterviews': completedInterviews,
      'avgRating': avgRating,
      'hireRate': hireRate,
      'yearsExperience': yearsExperience,
    };
  }
}

class Specialization {
  final String name;
  final SkillLevel level;

  Specialization({required this.name, required this.level});

  /// 🔄 Firestore → Model
  factory Specialization.fromMap(Map<String, dynamic> map) {
    return Specialization(
      name: map['name'] ?? '',
      level: _levelFromString(map['level']),
    );
  }

  /// 🔄 Model → Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'level': level.name};
  }

  /// 🔁 String → Enum
  static SkillLevel _levelFromString(String? level) {
    switch (level) {
      case 'expert':
        return SkillLevel.expert;
      case 'advanced':
        return SkillLevel.advanced;
      default:
        return SkillLevel.intermediate;
    }
  }

  /// 🎨 UI label
  String get levelLabel {
    switch (level) {
      case SkillLevel.expert:
        return "Expert";
      case SkillLevel.advanced:
        return "Advanced";
      default:
        return "Intermediate";
    }
  }
}
