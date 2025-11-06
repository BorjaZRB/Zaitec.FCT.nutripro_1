import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addTrackingRecord({
    required String userId,
    required String habitType,
    required int value,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking')
          .add({
        'user_id': userId,
        'habit_type': habitType,
        'timestamp': FieldValue.serverTimestamp(), 
        'value': value,
      });
    } catch (e) {
      debugPrint('Error al agregar el registro: $e');
      rethrow; 
    }
  }
  Stream<QuerySnapshot> getDailyTrackingStream(String userId) {
   DateTime now = DateTime.now();
   DateTime startOfToday = DateTime(now.year, now.month, now.day);
   DateTime startOfTomorrow = startOfToday.add(const Duration(days: 1));
   Timestamp startTimestamp = Timestamp.fromDate(startOfToday);
   Timestamp endTimestamp = Timestamp.fromDate(startOfTomorrow);

   return _firestore
       .collection('users')
       .doc(userId)
       .collection('tracking')
       .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
       .where('timestamp', isLessThan: endTimestamp)
       .orderBy('timestamp', descending: true) 
       .snapshots();
  }

  Future<List<QueryDocumentSnapshot>> getTrackingHistory(String userId,
      {int days = 7}) async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracking')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();
          
      return snapshot.docs;
    } catch (e) {
      debugPrint('Error al obtener historial de tracking: $e');
      return [];
    }
  }
}