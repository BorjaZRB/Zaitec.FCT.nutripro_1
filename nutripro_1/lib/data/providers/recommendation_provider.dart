import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutripro_1/data/models/recommendation_model.dart';

class RecommendationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'recommendations';

  Stream<List<Recommendation>> getUnreadRecommendationsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collectionPath)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();

      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addRecommendation(
      String userId, Recommendation recommendation) async {
    try {
      final collectionRef =
          _firestore.collection('users').doc(userId).collection(_collectionPath);

      final existing = await collectionRef
          .where('type',
              isEqualTo: recommendation.type.toString().split('.').last)
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await collectionRef.add(recommendation.toJson());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al agregar recomendación: $e');
      rethrow;
    }
  }

  Future<void> markRecommendationAsRead(
      String userId, String recommendationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection(_collectionPath)
          .doc(recommendationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error al marcar como leída: $e');
      rethrow;
    }
  }
}