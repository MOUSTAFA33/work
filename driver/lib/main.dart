import 'package:driver/screens/authenticate/login.dart';
import 'package:driver/screens/home/home_page.dart';
import 'package:driver/screens/home/loading.dart';
import 'package:driver/screens/home/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Driver App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => const LoadingPage(),
        '/login': (BuildContext context) => const LoginPage(),
        '/main': (BuildContext context) => const HomePage(),
        '/profile': (BuildContext context) => const DriverProfilePage(),
      },
    );
  }
}
