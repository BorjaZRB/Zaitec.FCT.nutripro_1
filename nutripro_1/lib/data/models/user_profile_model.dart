import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String? name;
  final double? waterGoal;
  final int? mealsPerDay;
  final int? calorieGoal;
  final double? weight;
  final double? height;
  final Timestamp createdAt;
  final bool isAdmin;

  UserProfile({
    required this.email,
    this.name,
    this.waterGoal,
    this.mealsPerDay,
    this.calorieGoal,
    this.weight,
    this.height,
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
      calorieGoal: (data['calorieGoal'] as num?)?.toInt(),
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
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
      'calorieGoal': calorieGoal,
      'weight': weight,
      'height': height,
      'createdAt': createdAt,
      'isAdmin': isAdmin,
    };
  }

  UserProfile copyWith({
    String? name,
    double? waterGoal,
    int? mealsPerDay,
    int? calorieGoal,
    double? weight,
    double? height,
    bool? isAdmin,
  }) {
    return UserProfile(
      email: email,
      name: name ?? this.name,
      waterGoal: waterGoal ?? this.waterGoal,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      createdAt: createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
