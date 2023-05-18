// ignore_for_file: use_build_context_synchronously

import 'package:driver/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;
  AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() async {
    User? user = await authService.getCurrentUser();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  Text(
                    'Loading ...',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  )
                ],
              )
            : const Text('اكتمل التحميل!'),
      ),
    );
  }
}
