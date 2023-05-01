import 'package:client/screens/authenticate/login.dart';
import 'package:client/screens/home/trip_page.dart';
import 'package:client/screens/home/home_page.dart';
import 'package:client/screens/home/loading.dart';
import 'package:client/screens/home/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter client App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => const LoadingPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/main': (BuildContext context) => const HomePage(),
        '/profile': (BuildContext context) => clientProfilePage(),
      },
    );
  }
}
