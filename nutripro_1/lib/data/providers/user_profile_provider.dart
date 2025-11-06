import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';

class UserProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> saveUserProfile(String userId, UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(profile.toMap(), SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error al guardar el perfil: $e');
      rethrow;
    }
  }
}