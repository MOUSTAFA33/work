import 'dart:async';

import 'package:client/screens/home/trip_page.dart';
import 'package:client/service/auth_service.dart';
import 'package:client/service/firestore_service.dart';
import 'package:client/service/location_service.dart';
import 'package:client/service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/client.dart';
import '../../models/driver.dart';
import '../../models/user_location.dart';
import '../../service/realtime_service.dart';
import 'CustomSearch.dart';
import 'Long_Trip_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final Completer<GoogleMapController> controller = Completer();
  late GoogleMapController _controller;
  StreamSubscription<LocationData>? locationSubscription;
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Driver? data;
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
  BitmapDescriptor? flagMarker, pinMarker, carMarker;
  LatLng? sourceLocation, destinationLocation, currentLocation, driverLocation;
  TextEditingController sourceLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  bool showDriver = false;
  bool _isSubWidgetVisible = true;
  Client? client;

  void toggleSubWidgetVisibility() {
    setState(() {
      _isSubWidgetVisible = !_isSubWidgetVisible;
    });
  }

  List<String> list = [];
  @override
  void initState() {
    super.initState();
    locationService.getCurrentLoc().then((value) => setState(() {
          currentLocation = value;
          sourceLocation = value;
          sourceLocationController.text =
              value.latitude.toString() + value.longitude.toString();
        }));
    notificationService.setupToken();
    fixIconMarker();
    getmessage();
    tracking();
    getClient();
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
  void dispose() {
    locationSubscription!.pause();
    locationSubscription!.cancel();
    super.dispose();
  }

  Future<void> getClient() async {
    String uid = await authService.getCurrentUserUid();
    client = await firestoreService.getUser(uid);
    print(client);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () async {
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
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
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
                    onTap: (position) {
                      // This method will be called when the user taps on the map.
                      // You can use it to add markers to the map.
                      setState(() {
                        if (sourceLocation == null) {
                          sourceLocation = position;
                          sourceLocationController.text =
                              "(${position.latitude}, ${position.longitude})";
                          print('add pickup');
                        } else if (destinationLocation == null) {
                          destinationLocation = position;
                          destinationLocationController.text =
                              "(${position.latitude}, ${position.longitude})";
                          print('add deste');
                        }
                      });
                    },
                    markers: {
                      if (sourceLocation != null)
                        locationService.getMarker(
                            sourceLocation,
                            BitmapDescriptor.defaultMarkerWithHue(0),
                            "my location"),
                      if (driverLocation != null)
                        Marker(
                          markerId: MarkerId(driverLocation!.toString()),
                          icon: carMarker!,
                          // icon: _locationIcon,
                          position: driverLocation!,
                          infoWindow: InfoWindow(
                              title: "Driver Location",
                              snippet:
                                  "${driverLocation?.latitude}, ${driverLocation?.longitude}"),
                        ),
                      if (destinationLocation != null)
                        Marker(
                          markerId: MarkerId(destinationLocation!.toString()),
                          icon: flagMarker!,
                          // icon: _locationIcon,
                          position: destinationLocation!,
                          infoWindow: InfoWindow(
                              title: "Distanation Locatio",
                              snippet:
                                  "${destinationLocation?.latitude}, ${destinationLocation?.longitude}"),
                        )
                    }),
                // _isSubWidgetVisible == true
                //     ?
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Color.fromARGB(255, 255, 255, 255),
                    height: 210,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextField(
                              enabled: false,
                              readOnly: true,
                              controller: sourceLocationController,
                              decoration: InputDecoration(
                                hintText: 'Your Location',
                                label: Text(
                                  'Your Location',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                icon: Icon(Icons.location_pin),
                                border: OutlineInputBorder(gapPadding: 1),
                                suffixIcon: GestureDetector(
                                  onTap: () async {},
                                  child: Icon(Icons.search),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  sourceLocation = null;
                                });
                                sourceLocationController.text = "";
                              },
                            ),
                            TextField(
                              readOnly: true,
                              controller: destinationLocationController,
                              decoration: InputDecoration(
                                hintText: 'Distanation Location',
                                label: Text(
                                  'Distanation Location',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                icon: Icon(Icons.flag_rounded),
                                border: OutlineInputBorder(gapPadding: 1),
                                suffixIcon: GestureDetector(
                                  onTap: () {},
                                  child: Icon(Icons.search),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  destinationLocation = null;
                                });
                                destinationLocationController.text = "";
                              },
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  debugPrint(sourceLocation.toString());
                                  debugPrint(destinationLocation.toString());

                                  realtimeService
                                      .readDriver(sourceLocation!, list)
                                      .then((value) {
                                    driverLocation = value!.myLocation;
                                    list.add(value.id);
                                    firestoreService.getDrivers(value.id).then(
                                        (value) =>
                                            TripContainer().showBoxDriver(
                                              context,
                                              value,
                                              driverLocation,
                                              sourceLocation,
                                              destinationLocation,
                                              _isSubWidgetVisible,
                                              client!,
                                              toggleSubWidgetVisibility,
                                            ));
                                  });
                                },
                                child: const Text('Find Driver'))
                          ]),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            child: IconButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              color: Colors.green,
                              icon: const Icon(Icons.travel_explore_outlined),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => const LongTrip()));
                              },
                            )),
                        IconButton(
                          onPressed: () async {
                            // method to show the search bar
                            final result = await showSearch(
                                context: context,
                                // delegate to customize the search bar
                                delegate: CustomSearchDelegate());
                            if (result != null) {
                              setState(() {
                                destinationLocation = result;
                                destinationLocationController.text =
                                    destinationLocation!.latitude.toString() +
                                        destinationLocation!.longitude
                                            .toString();
                                //
                              });
                            }
                            print("destinationLocation = $destinationLocation");
                          },
                          icon: const Icon(Icons.search),
                        )
                      ],
                    ))
                // : Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: const [
                //         CircularProgressIndicator(
                //           color: Colors.blue,
                //         ),
                //         Text(
                //           'Wating for response',
                //           style:
                //               TextStyle(fontSize: 20, color: Colors.black),
                //         )
                //       ],
                //     ),
                //   )
              ],
            ),
    );
  }

  void tracking() {
    locationSubscription =
        locationService.location.onLocationChanged.listen((newloc) async {
      currentLocation = LatLng(newloc.latitude!, newloc.longitude!);
      // print(currentLocation);
      // locationService
      //     .animateCameraPos(LatLng(newloc.latitude!, newloc.longitude!));
      realtimeService.updateData(UserLocation(
          await authService.getCurrentUserUid(),
          "client",
          LatLng(newloc.latitude!, newloc.longitude!)));
      setState(() {});
    });
  }

  void getmessage() {
    // Configure Firebase Messaging to listen for incoming messages
    print("object lesining .....................");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
      // Parse the message data as a JSON string

      if (message.notification?.body == "Your driver accepted the request and in his way to you") {
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
                        'the driver is coming',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text(
                          'your request is accepted the driver is coming',
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
                        Navigator.pop(context);
                        return;
                      },
                      child: const Text('ok'),
                    ),
                  ]);
            });
      } else {
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
                        'the driver is busy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text(
                          'your driver is not coming choose an other driver',
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
                        realtimeService
                            .readDriver2(sourceLocation!, list)
                            .then((value) {
                          driverLocation = value!.myLocation;
                          list.add(value.id);
                          firestoreService
                              .getDrivers(value.id)
                              .then((value) => TripContainer().showBoxDriver(
                                    context,
                                    value,
                                    driverLocation,
                                    sourceLocation,
                                    destinationLocation,
                                    _isSubWidgetVisible,
                                    client!,
                                    toggleSubWidgetVisibility,
                                  ));
                        });
                      },
                      child: const Text('search for an other '),
                    ),
                  ]);
            });
      }
    });

    // Configure Firebase Messaging to listen for messages that were received while the app was in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from notification: ${message.notification?.title}');
      print('Message data: ${message.data}');
    });
  }
}
