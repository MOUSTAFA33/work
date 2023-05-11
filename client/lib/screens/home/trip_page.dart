import 'package:client/screens/home/wait.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/client.dart';
import '../../models/driver.dart';
import '../../models/notifications.dart';
import '../../models/trip.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../../service/notification_service.dart';
import 'dart:math' show cos, sqrt, asin;

class TripContainer {
  FirestoreService firestoreService = FirestoreService();
  AuthService authService = AuthService();
  NotificationService notificationService = NotificationService();
  void makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void openMapRoute(
      double fromLat, double fromLng, double toLat, double toLng) async {
    // final String googleMapsUrl =
    //     'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving';

    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  double calculatePrice(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    print("price===================\t\t\t $distance");
    if (distance < 3) {
      return 100;
    } else if (distance > 3 && distance < 4) {
      return 200;
    } else if (distance > 4 && distance < 10) {
      return 300;
    } else if (distance > 10) {
      return (distance * 80);
    }
    return (distance * 80);
  }

  bool onPressedValue = true;
  void showBoxDriver(
      BuildContext context,
      Driver? data,
      LatLng? driverLocation,
      LatLng? sourceLocation,
      LatLng? destinationLocation,
      bool _isSubWidgetVisible,
      Client client,
      VoidCallback onVisibilityChanged) {
    double prix = calculatePrice(
        sourceLocation!.latitude,
        sourceLocation.longitude,
        destinationLocation!.latitude,
        destinationLocation.longitude);
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return data == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  height: 340,
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
                            Text(
                              'Your Trip',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(" $prix DZD"),
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
                                sourceLocation.latitude.toString() +
                                    ", " +
                                    sourceLocation.longitude.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
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
                                    : destinationLocation.latitude.toString() +
                                        ", " +
                                        destinationLocation.longitude
                                            .toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          thickness: 2,
                          color: Colors.black,
                        ),
                        Text(
                          'Your selected Driver',
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
                            subtitle: Text("Lat: " +
                                driverLocation!.latitude.toString() +
                                ",Lng: " +
                                driverLocation.longitude.toString()),
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
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    openMapRoute(
                                        driverLocation.latitude,
                                        driverLocation.longitude,
                                        sourceLocation.latitude,
                                        sourceLocation.longitude);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isSubWidgetVisible)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.arrow_back)),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                  onPressed: () async {
                                    //send notification
                                    Client c = await firestoreService.getUser(
                                        await authService.getCurrentUserUid());
                                    notificationService.sendPushMessage(
                                        Notifications(
                                            c.id,
                                            c.token,
                                            data.token,
                                            Trip(sourceLocation,
                                                destinationLocation),
                                            prix),
                                        client);
                                    Navigator.pop(context);
                                    return showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const FixedAlertDialog();
                                      },
                                    );
                                    onVisibilityChanged();
                                  },
                                  child: const Text('Ask For Driver'))
                            ],
                          ),
                      ]),
                );
        });
  }
}
