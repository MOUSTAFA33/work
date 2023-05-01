import 'package:client/models/client.dart';
import 'package:client/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      debugPrint(e as String?);
      return null;
    }
  }

  Future<String> getCurrentUserUid() async {
    String uid = await _auth.currentUser!.uid;
    return uid;
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

      Client current = Client(authResult.user!.uid, name, email, phone, token!);
      await _firestore.createDriver(current);
      debugPrint('auth=$authResult');
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    User? user = _auth.currentUser;
    return user;
  }
}
