// lib/services/firestore_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveSurveyData(String uid, Map<String, dynamic> surveyData) async {
    final docRef = _db.collection('users').doc(uid);

    await docRef.set({
      ...surveyData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));


    final snap = await docRef.get();
    final data = snap.data();

    if (data == null || !data.containsKey('calories')) {
      await createDashboardFromSurvey(uid);
    }
  }


  Future<void> createDashboardFromSurvey(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final snap = await userRef.get();
    final data = snap.data() ?? {};


    final int weight = (data['weight'] is num) ? (data['weight'] as num).toInt() : 70;
    final int height = (data['height'] is num) ? (data['height'] as num).toInt() : 170;
    final int exerciseMinutes = (data['exerciseMinutes'] is num)
        ? (data['exerciseMinutes'] as num).toInt()
        : 30;
    final int mealsPerDay = (data['mealsPerDay'] is num) ? (data['mealsPerDay'] as num).toInt() : 3;
    final int waterGoal = (data['waterGoal'] is num) ? (data['waterGoal'] as num).toInt() : 2;

    final calories = _recommendedCalories(weight, height, exerciseMinutes).round();
    final progress = _initialGoalProgress(exerciseMinutes, waterGoal);
    final weekly = _buildWeekly(exerciseMinutes);
    final monthly = _buildMonthly(exerciseMinutes);

    await userRef.set({
      'calories': calories,
      'meals': mealsPerDay,
      'water': waterGoal.toDouble(),
      'goalsProgress': progress,
      'weeklyData': weekly,
      'monthlyData': monthly,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

 
  Future<void> updateUserProgress(String uid) async {
    final userRef = _db.collection('users').doc(uid);

  
    final snap = await userRef.get();
    final data = snap.data() ?? {};

    final weekly = (data['weeklyData'] is List)
        ? List<double>.from((data['weeklyData'] as List).map((e) => (e as num).toDouble()))
        : _buildWeekly(30);


    final newWeekly = weekly.map((v) => (v + (Random().nextDouble() * 2 - 1)).clamp(0.0, 50.0)).toList();

    final monthly = (data['monthlyData'] is List)
        ? List<double>.from((data['monthlyData'] as List).map((e) => (e as num).toDouble()))
        : _buildMonthly(30);

    final newMonthly = monthly.map((v) => (v + (Random().nextDouble() * 4 - 2)).clamp(0.0, 500.0)).toList();

    await userRef.update({
      'weeklyData': newWeekly,
      'monthlyData': newMonthly,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }


  double _recommendedCalories(int weight, int height, int exerciseMinutes) {

    double bmr = (10 * weight) + (6.25 * height) - (5 * 25) + 5;
    double activityFactor = 1.2 + (exerciseMinutes / 300);
    if (activityFactor > 1.8) activityFactor = 1.8;
    return bmr * activityFactor;
  }

  double _initialGoalProgress(int exerciseMinutes, int waterGoal) {
    double score = (exerciseMinutes / 60) * 0.6 + (waterGoal / 4) * 0.4;
    if (score < 0.05) score = 0.05;
    if (score > 0.95) score = 0.95;
    return score;
  }

  List<double> _buildWeekly(int exerciseMinutes) {
    return List.generate(7, (i) {
      double val = (exerciseMinutes / 15.0) + (i % 3) * 1.0;
      return double.parse(val.toStringAsFixed(1));
    });
  }

  List<double> _buildMonthly(int exerciseMinutes) {
    return List.generate(6, (i) {
      double val = (exerciseMinutes / 5.0) + i * 2.0;
      return double.parse(val.toStringAsFixed(1));
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserDocument(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<Map<String, dynamic>?> readUserDoc(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }
}
