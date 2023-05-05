import 'package:client/models/client.dart';
import 'package:client/models/driver.dart';
import 'package:client/service/auth_service.dart';
import 'package:client/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class clientProfilePage extends StatefulWidget {
  const clientProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _clientProfilePageState createState() => _clientProfilePageState();
}

class _clientProfilePageState extends State<clientProfilePage> {
  FirestoreService firestoreService = FirestoreService();
  AuthService authService = AuthService();
  Client? client;

  void initState() {
    super.initState();
    getClient();
  }

  Future<void> getClient() async {
    String uid = await authService.getCurrentUserUid();
    client = await firestoreService.getUser(uid);
    print(client);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return client != null
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: Colors.green[700],
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    authService.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            body: client == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 64,
                            //backgroundImage: AssetImage('images/back_img.jpg'),
                            child: Icon(Icons.person, size: 64, color: Colors.white,)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Name : ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              client!.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Email : ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                client!.email,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Phone : ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                client!.phone,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ]),
                        ElevatedButton(
                          child: const Text('Edit Profile'),
                          onPressed: () {
                            // Implement edit profile functionality
                          },
                        ),
                      ],
                    ),
                  ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
