import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutripro_1/data/models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Stream<List<UserProfile>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userProfile.toMap());
      _userProfile = userProfile;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(userProfile.toMap());
      _userProfile = userProfile;
      notifyListeners();
    }
  }

  Future<void> updateField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
      notifyListeners();
    }
  }

  Future<UserProfile?> get currentUserProfile async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
        notifyListeners();
        return _userProfile;
      }
    }
    return null;
  }

  Future<void> saveUserProfile(String uid, UserProfile updatedProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error en saveUserProfile: $e');
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar usuario: $e');
      rethrow;
    }
  }
}
