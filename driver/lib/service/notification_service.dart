import 'dart:convert';

import 'package:driver/service/auth_service.dart';
import 'package:driver/service/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/client.dart';
import '../models/driver.dart';
import '../models/notifications.dart';
import '../screens/home/alert_notif.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  AuthService authService = AuthService();
  FirestoreService firestoreService = FirestoreService();

  Future<void> setupToken() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    messaging.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    String userId = await authService.getCurrentUserUid();
    print(token);
    await firestoreService.driversCollectionRef.doc(userId).update({
      'token': token,
    });
  }

  Future<void> sendPushMessage(
      Notifications notifications, String state) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAA_FIV9v8:APA91bEyx7IiWrJZ7zCn_wWBMsM38R2TZuKykRYm5JPVRppnKEE8DvY2_Wqka8LkTMGOVe0yznrF75QZHAiftU1bsZjjUKrVzcUHHM2C5n7VHayZOm8V05vq_EUsQlT2ZM2QcZrQWzYJ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            "notification": {"title": "your driver did respond", "body": state == "accept" ? "Your driver accepted the request and in his way to you" : "Your driver refused the request please choose another driver" },
            'data': {'data': notifications.toJson()},
            "to": notifications.driverToken,
          },
        ),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print("is $e");
    }
  }
}
