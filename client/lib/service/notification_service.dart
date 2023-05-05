import 'dart:convert';

import 'package:client/service/auth_service.dart';
import 'package:client/service/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;

import '../models/client.dart';
import '../models/notifications.dart';

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
    String? token = await messaging.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    messaging.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    String userId = await authService.getCurrentUserUid();

    await firestoreService.clientsCollectionRef.doc(userId).update({
      'token': token,
    });
  }

  Future<void> sendPushMessage(Notifications notifications, Client client) async {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((notifications.cordinate.distenation!.latitude - notifications.cordinate.source!.latitude) * p)/2 + 
          c(notifications.cordinate.source!.latitude * p) * c(notifications.cordinate.distenation!.latitude * p) * 
          (1 - c((notifications.cordinate.distenation!.longitude - notifications.cordinate.source!.longitude) * p))/2;
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
            "notification": {"title": "${client.name} asked for a Driver!", "body": "Trip Distance: ${12742 * asin(sqrt(a))} Km"},
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

  void getmessage() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      final notification = message.notification;
      Notifications data =
          Notifications.fromData(jsonDecode(notification!.body!));
      // Driver? driver;
      // firestore.getUser(authService.getCurrentUid()!).then((value) => driver=value);
      debugPrint("message has get");
    });
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print("Handling a background message: ${message.messageId}");
  }

  void inBackGround() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
