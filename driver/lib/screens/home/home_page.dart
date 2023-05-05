import 'dart:async';
import 'dart:convert';
import 'package:driver/models/notifications.dart';
import 'package:driver/screens/home/long_trip_page.dart';
import 'package:driver/screens/home/trip_page.dart';
import 'package:driver/service/auth_service.dart';
import 'package:driver/service/firestore_service.dart';
import 'package:driver/service/location_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../models/user_location.dart';
import '../../service/notification_service.dart';
import '../../service/realtime_service.dart';
import 'alert_notif.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController _controller;
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor? flagMarker, pinMarker, carMarker;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _loadVisibleRegion() {
    LatLngBounds visibleRegion;
    _controller.getVisibleRegion().then((value) => setState(() {
          visibleRegion = value;
        }));
    // load the portion of the map defined by visibleRegion
  }

  LocationService locationService = LocationService();
  FirestoreService firestoreService = FirestoreService();
  AuthService authService = AuthService();
  NotificationService notificationService = NotificationService();
  RealtimeService realtimeService = RealtimeService();
  // PopMenus PM=PopMenus();

  LatLng? sourceLocation, destinationLocation;
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();

  List<LatLng> polylineCoordinates = [];
  bool showDriver = false;

  LatLng? currentLocation;

  @override
  void initState() {
    locationService.getCurrentLoc().then((value) => setState(() {
          currentLocation = value;
          sourceLocation = value;
        }));
    super.initState();
    fixIconMarker();

    notificationService.setupToken();
    tracking();
    getmessage();
  }

  @override
  void dispose() {
    locationSubscription!.pause();
    locationSubscription!.cancel();
    super.dispose();
  }

  Future<void> fixIconMarker() async {
    pinMarker = await locationService
        .createBitmapDescriptorFromIcon(Icons.location_pin);
    flagMarker =
        await locationService.createBitmapDescriptorFromIcon(Icons.flag);
    carMarker = await locationService
        .createBitmapDescriptorFromIcon(Icons.directions_car_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: "notifications_btn",
          //   onPressed: () {
          //     // Add your onPressed code here!
          //   },
          //   backgroundColor: Colors.green,
          //   child:  Icon(Icons.notifications),
          // ),
          // SizedBox(height: 5,),
          FloatingActionButton(
            heroTag: "Trip_btn",
            onPressed: () {
              Navigator.push((context),
                  MaterialPageRoute(builder: (context) => TripPage()));
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.travel_explore_outlined),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_rounded)),
        title: const Text('Home Page'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          backgroundColor: Colors.black45,
                          title: Row(
                            children: const [
                              Icon(
                                Icons.mode_night_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'log out Mode',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: const <Widget>[
                                Text(
                                  ' are you sure  you want to log out ?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () async {
                                authService.getCurrentUserUid().then((value) {
                                  realtimeService.deleteData(value);
                                  powerOn(false);
                                  authService.signOut();
                                  Navigator.pushReplacementNamed(context, '/');
                                });
                              },
                              child: const Text('ON'),
                            ),
                          ]);
                    });
              },
              icon: const Icon(Icons.exit_to_app_sharp))
        ],
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: currentLocation == null || carMarker == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              GoogleMap(
                  // liteModeEnabled: true,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 14,
                  ),
                  onCameraMove: (CameraPosition position) {
                    _loadVisibleRegion();
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId(currentLocation!.toString()),
                      icon: carMarker!,
                      // icon: _locationIcon,
                      position: currentLocation!,
                      infoWindow: InfoWindow(
                          title: "mylocation",
                          snippet:
                              "${currentLocation?.latitude}, ${currentLocation?.longitude}"),
                    )
                  }),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircleAvatar(
                          backgroundColor: Colors.black,
                          child: IconButton(
                              color: Colors.white,
                              icon: const Icon(Icons.power_settings_new),
                              onPressed: () {
                                powerOn(false);

                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.black45,
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.mode_night_outlined,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Sleep Mode',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: const <Widget>[
                                              Text(
                                                'push the On button to start working',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              powerOn(true);
                                            },
                                            child: const Text('ON'),
                                          ),
                                        ],
                                      );
                                    });
                              })))),
            ]),
    );
  }

  void tracking() {
    locationSubscription =
        locationService.location.onLocationChanged.listen((newloc) async {
      currentLocation = LatLng(newloc.latitude!, newloc.longitude!);
      // print(currentLocation);
      locationService
          .animateCameraPos(LatLng(newloc.latitude!, newloc.longitude!));
      realtimeService.updateData(UserLocation(
          await authService.getCurrentUserUid(),
          "driver",
          LatLng(newloc.latitude!, newloc.longitude!)));
      setState(() {});
    });
  }

  void powerOn(isAvalaible) async {
    String uid = await authService.getCurrentUserUid();
    firestoreService.OnUser(isAvalaible, uid);
    if (isAvalaible == false) {
      locationSubscription!.pause();
      realtimeService.deleteData(uid);
    } else {
      locationSubscription?.resume();
      realtimeService.updateData(UserLocation(uid, "driver",
          LatLng(currentLocation!.latitude, currentLocation!.longitude)));
    }
  }

  void getmessage() {
    // Configure Firebase Messaging to listen for incoming messages
    print("object lesining .....................");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      // Parse the message data as a JSON string
      String dataJson = message.data['data'];

      // Decode the JSON string into a Map<String, dynamic> object
      Map<String, dynamic> data = jsonDecode(dataJson);
      print('Message data: ${data}');

      // Extract the relevant data from the Map and convert it into an object
      Notifications notifications = Notifications.fromData(data);
      sourceLocation = notifications.cordinate.source;
      destinationLocation = notifications.cordinate.distenation;
      final prix = notifications.prix;

      firestoreService.getClient(notifications.id).then((value) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              name: value.name,
              email: value.email,
              phone: value.phone,
              sourceLocation: notifications.cordinate.source!,
              destinationLocation: notifications.cordinate.distenation!,
            );
          },
        ).then((response) async {
          // handle user response
          if (response == true) {
            notificationService.sendPushMessage(
                Notifications(notifications.id, notifications.driverToken,
                    notifications.clientToken, notifications.cordinate, notifications.prix),
                "accept");
            realtimeService.readClient(notifications.id).then((value) async {
              TripContainer().showBoxDriver(
                context,
                await firestoreService.getClient(notifications.id),
                currentLocation,
                sourceLocation!,
                destinationLocation!,
                prix
              );
            });
          } else if (response == false) {
            notificationService.sendPushMessage(
                Notifications(notifications.id, notifications.driverToken,
                    notifications.clientToken, notifications.cordinate, notifications.prix),
                "refuse");
          }
        });
      });
    });

    // Configure Firebase Messaging to listen for messages that were received while the app was in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      // Parse the message data as a JSON string
      String dataJson = message.data['data'];

      // Decode the JSON string into a Map<String, dynamic> object
      Map<String, dynamic> data = jsonDecode(dataJson);
      print('Message data: ${data}');

      // Extract the relevant data from the Map and convert it into an object
      Notifications notifications = Notifications.fromData(data);
      sourceLocation = notifications.cordinate.source;
      destinationLocation = notifications.cordinate.distenation;
      final prix = notifications.prix;

      firestoreService.getClient(notifications.id).then((value) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              name: value.name,
              email: value.email,
              phone: value.phone,
              sourceLocation: notifications.cordinate.source!,
              destinationLocation: notifications.cordinate.distenation!,
            );
          },
        ).then((response) async {
          // handle user response
          if (response == true) {
            notificationService.sendPushMessage(
                Notifications(notifications.id, notifications.driverToken,
                    notifications.clientToken, notifications.cordinate, notifications.prix),
                "accept");
            realtimeService.readClient(notifications.id).then((value) async {
              TripContainer().showBoxDriver(
                  context,
                  await firestoreService.getClient(notifications.id),
                  currentLocation,
                  sourceLocation!,
                  destinationLocation!,
                  prix);
            });
          } else if (response == false) {
            notificationService.sendPushMessage(
                Notifications(notifications.id, notifications.driverToken,
                    notifications.clientToken, notifications.cordinate, notifications.prix),
                "refuse");
          }
        });
      });
    });
  }
}
