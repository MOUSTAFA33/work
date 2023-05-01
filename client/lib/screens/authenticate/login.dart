// ignore_for_file: use_build_context_synchronously

import 'package:client/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home/loading.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      dynamic user = await _auth.signInWithEmailAndPassword(_email, _password);
      if (user != null) {
        Fluttertoast.showToast(
            msg: "Welcome to the home page",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black12,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Fluttertoast.showToast(
            msg: "Wrong username or password",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: _isLoading
            ? const LoadingPage()
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      const Text("Log In ",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Email cannot be empty' : null,
                        onChanged: (value) {
                          setState(() {
                            _email = value.trim();
                          });
                        },
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                          labelText: "emil",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        validator: (value) =>
                            value!.isEmpty ? 'Password cannot be empty' : null,
                        obscureText: true,
                        onChanged: (value) {
                          setState(() {
                            _password = value.trim();
                          });
                        },
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock, color: Colors.grey),
                          labelText: "password",
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreenAccent),
                          child: const Text(" Log in",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ))),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text("I alredy have an account! ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              )),
                          TextButton(
                              onPressed: () async {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => const SignUpPage()));
                              },
                              child: const Text("Sign up",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                  )))
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }
}
