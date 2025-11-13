import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String? name;
  final double? waterGoal;
  final int? mealsPerDay;
  final int? exerciseMinutes;
  final double? weight;
  final double? height;
  final bool profileCompleted;
  final Timestamp createdAt;
  final bool isAdmin;

  UserProfile({
    required this.email,
    this.name,
    this.waterGoal,
    this.mealsPerDay,
    this.exerciseMinutes,
    this.weight,
    this.height,
    this.profileCompleted = false,
    required this.createdAt,
    this.isAdmin = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      email: data['email'] ?? '',
      name: data['name'],
      waterGoal: (data['waterGoal'] as num?)?.toDouble(),
      mealsPerDay: (data['mealsPerDay'] as num?)?.toInt(),
      exerciseMinutes: (data['exerciseMinutes'] as num?)?.toInt(),
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      profileCompleted: data['profileCompleted'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'waterGoal': waterGoal,
      'mealsPerDay': mealsPerDay,
      'exerciseMinutes': exerciseMinutes,
      'weight': weight,
      'height': height,
      'profileCompleted': profileCompleted,
      'createdAt': createdAt,
      'isAdmin': isAdmin,
    };
  }

  UserProfile copyWith({
    String? name,
    double? waterGoal,
    int? mealsPerDay,
    int? exerciseMinutes,
    double? weight,
    double? height,
    bool? profileCompleted,
    bool? isAdmin,
  }) {
    return UserProfile(
      email: email,
      name: name ?? this.name,
      waterGoal: waterGoal ?? this.waterGoal,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}