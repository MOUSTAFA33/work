import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'dart:convert';

import '../../models/client.dart';
import '../../models/driver.dart';
import '../../models/notifications.dart';
import '../../models/trip.dart';
import '../../models/user_location.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../../service/location_service.dart';
import '../../service/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../service/realtime_service.dart';

class TripContainer {
  final CollectionReference clientsCollectionRef =
      FirebaseFirestore.instance.collection("clients");
  final CollectionReference driversCollectionRef =
      FirebaseFirestore.instance.collection("drivers");
  final CollectionReference RidesCollectionRef =
      FirebaseFirestore.instance.collection("rides");
  FirestoreService firestoreService = FirestoreService();
  AuthService authService = AuthService();
  NotificationService notificationService = NotificationService();
  final jsonEncoder = JsonEncoder();
  StreamSubscription<LocationData>? locationSubscription;
  RealtimeService realtimeService = RealtimeService();

  void makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void openMapRoute(
      double fromLat, double fromLng, double toLat, double toLng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving';
    if (await canLaunchUrl(Uri.parse('tel:$googleMapsUrl'))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  void openTripMapRoute(double fromLat, double fromLng, double toLat1,
      double toLng1, double toLat2, double toLng2) async {
    // final String googleMapsUrl =
    //     'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving';

    final String googleMapsUrl =
        'https://www.google.com/maps/dir/$fromLat,$fromLng/$toLat1,$toLng1/$toLat2,$toLng2';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  bool clientwaspickedup = false;
  void showBoxDriver(
      BuildContext context,
      ClienT? data,
      LatLng? MyCurrentLocation,
      LatLng? sourceLocation,
      LatLng? destinationLocation,
      double prix,
      String clientid,
      String driverid) {
    showModalBottomSheet(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        builder: (_) => StatefulBuilder(
            builder: (modalContext, modalSetState) => Container(
                  child: data == null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Your Trip',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("$prix DZD"),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.blue[500],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            sourceLocation.toString(),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          color: Colors.green[500],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            destinationLocation == null
                                                ? 'Undefined ...'
                                                : destinationLocation
                                                    .toString(),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(
                                      thickness: 2,
                                      color: Colors.black,
                                    ),
                                    const Text(
                                      'Your selected Deiver',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 10),
                                    Card(
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.directions_car,
                                          color: Colors.red[400],
                                        ),
                                        title: Text(data.name),
                                        // subtitle:
                                        //     Text(driverLocation!.myLocation.toString()),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              color: Colors.blue,
                                              icon: const Icon(Icons.call),
                                              onPressed: () {
                                                makePhoneCall(data.phone);
                                              },
                                            ),
                                            IconButton(
                                              color: Colors.green,
                                              icon:
                                                  const Icon(Icons.directions),
                                              onPressed: () {
                                                openTripMapRoute(
                                                    destinationLocation!
                                                        .latitude,
                                                    destinationLocation
                                                        .longitude,
                                                    sourceLocation!.latitude,
                                                    sourceLocation.longitude,
                                                    MyCurrentLocation!.latitude,
                                                    MyCurrentLocation
                                                        .longitude);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        clientwaspickedup
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  change(clientid, driverid,
                                                      false);
                                                  modalSetState(() {
                                                    clientwaspickedup = false;
                                                  });

                                                  notificationService.sendFeedbackMessage(
                                                          data.token,
                                                          driverid,
                                                          clientid);
                                                },
                                                child: const Text('finished'))
                                            : ElevatedButton(
                                                onPressed: () async {
                                                  change(
                                                      clientid, driverid, true);
                                                  modalSetState(() {
                                                    clientwaspickedup = true;
                                                  });
                                                },
                                                child: const Text('Picked up'))
                                      ],
                                    ),
                                  ]),
                            ),
                        ),
                )));
  }

  sendFeedbacktoclient() {
    NotificationService notificationService = NotificationService();
    // notificationService.sendPushMessage(
    //             Notifications(
    //                 notifications.id,
    //                 notifications.driverToken,
    //                 notifications.clientToken,
    //                 notifications.cordinate,
    //                 notifications.prix),
    //             "accept");
  }

  void change(clientID, driverid, bool ispickedup) async {
    Response response = await get(
        Uri.http('worldtimeapi.org', '/api//timezone/Africa/Algiers'));
    var date = json.decode(response.body);
    String name = date['datetime'].substring(0, 10);
    print("unixtime:::::::::::::::\t\t" + name);
    testifdocexists(name);
    if (ispickedup) {
      await clientsCollectionRef.doc(clientID).update({"ispickedup": true});
      busyornot(true, driverid);
      addTripLog(name, date['unixtime'], clientID, driverid);
    } else {
      await clientsCollectionRef.doc(clientID).update({"ispickedup": false});
      busyornot(false, driverid);
    }
  }

  testifdocexists(date) async {
    print("date ===\t\t\t $date");
    bool? exist;
    try {
      await RidesCollectionRef.doc(date.toString()).get().then((doc) async {
        print(doc);
        exist = doc.exists;
        // ignore: curly_braces_in_flow_control_structures
        if (exist != null) {
          if (!exist!) {
            await RidesCollectionRef.doc(date.toString()).set({
              'ride': [],
              'date': date,
            }).then((value) {});
            return true;
          }
        }
        ;
      });
    } catch (e) {
      // If any error
      print(e);
    }
  }

  busyornot(bool busy, driverid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("drivers/" + driverid);
    String value;
    if (busy) {
      value = "yes";
    } else {
      value = "no";
    }

    await ref.update({
      "isbusy": value,
    });
  }

  addTripLog(date, time, clientid, driverid) async {
    var jsonArray = [
      {
        "driver": driverid,
        "client": clientid,
        "time": time,
      }
    ];

    await RidesCollectionRef.doc(date)
        .update({"ride": FieldValue.arrayUnion(jsonArray)});
  }
}
