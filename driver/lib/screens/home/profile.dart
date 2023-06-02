import 'package:driver/models/driver.dart';
import 'package:driver/service/auth_service.dart';
import 'package:driver/service/firestore_service.dart';
import 'package:flutter/material.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  FirestoreService firestoreService = FirestoreService();
  AuthService authService = AuthService();
  Driver? driver;

  void initState() {
    super.initState();

    getDriver();
  }

  Future<void> getDriver() async {
    String uid = await authService.getCurrentUserUid();
    driver = await firestoreService.getUser(uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text('الملف الشخصي للسائق'),
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
        body: driver == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const CircleAvatar(
                      radius: 64,
                      backgroundImage: AssetImage('assets/images/back_img.jpg'),
                      // child: Icon(Icons.person, size: 8)
                    ),
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
                          driver!.name,
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
                            driver!.email,
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
                            driver!.phone,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ]),
                    // ElevatedButton(
                    //   child: const Text('Edit Profile'),
                    //   style: ButtonStyle(
                    //     backgroundColor: MaterialStatePropertyAll(Colors.green[700],)
                    //   ),
                    //   onPressed: () {
                    //     // Implement edit profile functionality
                    //   },
                    // ),
                  ],
                ),
              ));
  }
}
