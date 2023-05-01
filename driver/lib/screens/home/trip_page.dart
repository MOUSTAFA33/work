import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/client.dart';
import '../../models/driver.dart';
import '../../models/notifications.dart';
import '../../models/trip.dart';
import '../../models/user_location.dart';
import '../../service/auth_service.dart';
import '../../service/firestore_service.dart';
import '../../service/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving';
    if (await canLaunchUrl(Uri.parse('tel:$googleMapsUrl'))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not open the map.';
    }
  }

  void showBoxDriver(
      BuildContext context,
      Client? data,
      UserLocation? driverLocation,
      LatLng? sourceLocation,
      LatLng? destinationLocation) {
    showModalBottomSheet(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return data == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  height: 300,
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
                        const Text(
                          'Your Trip',
                          style: TextStyle(fontSize: 15),
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
                                style: const TextStyle(fontSize: 20),
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
                                    : destinationLocation.toString(),
                                style: const TextStyle(fontSize: 20),
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
                                  icon: const Icon(Icons.directions),
                                  onPressed: () {
                                    openMapRoute(
                                        destinationLocation!.latitude,
                                        destinationLocation.longitude,
                                        sourceLocation!.latitude,
                                        sourceLocation.longitude);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: const Text('finished'))
                          ],
                        ),
                      ]),
                );
        });
  }
}
