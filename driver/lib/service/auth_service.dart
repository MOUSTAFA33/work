import 'package:driver/models/driver.dart';
import 'package:driver/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      String? token = await FirebaseMessaging.instance.getToken();
      await _firestoreService.driversCollectionRef
          .doc(result.user!.uid)
          .update({
        'token': token,
      });
      return result.user;
    } catch (e) {
      // debugPrint(e as String?);
      return null;
    }
  }

  Future<String> getCurrentUserUid() async {
    String uid = await _auth.currentUser!.uid;
    return uid;
  }

  Future<User?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return user;
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String isAvailable,
  }) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String? token = await FirebaseMessaging.instance.getToken();

      Driver current =
          Driver(authResult.user!.uid, name, email, phone, isAvailable, token!);
      await _firestoreService.createDriver(current);
      debugPrint('auth=$authResult');
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
