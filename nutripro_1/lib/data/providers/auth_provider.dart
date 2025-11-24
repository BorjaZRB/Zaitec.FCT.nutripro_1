import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        String userId = userCredential.user!.uid;
        await _firestore.collection('users').doc(userId).set({
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': false,
        });
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    debugPrint('Correo de recuperación enviado a $email');
  } catch (e) {
    debugPrint('Error al enviar correo de recuperación: $e');
    throw Exception('No se pudo enviar el correo de recuperación');
  }
}


  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
