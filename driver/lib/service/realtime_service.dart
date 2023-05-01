import 'package:driver/models/user_location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/driver.dart';
import 'firestore_service.dart';
import 'dart:math' as math;

class RealtimeService {
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref('drivers');
  final FirestoreService firestore = FirestoreService();

  void write(UserLocation userLocation) async {
    try {
      final snapshot = await databaseReference.child(userLocation.id).get();
      if (!snapshot.exists) {
        await databaseReference
            .child(userLocation.id)
            .set(userLocation.toJson());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<Driver>> read() async {
  //   try {
  //     List<Driver> ls = [];
  //     final snapshot = await databaseReference.get();
  //     if (snapshot.exists) {
  //       Map<String, dynamic> snapshotValue =
  //           Map<String, dynamic>.from(snapshot.value as Map);
  //       if (snapshotValue.values.toList().isNotEmpty) {
  //         for (var i in snapshotValue.values.toList()) {
  //           Driver client = await firestore.getDrivers(i['id']);
  //           ls.add(client);
  //         }
  //       }
  //     }
  //     return ls;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<UserLocation?> readClient(String id) async {
    try {
      final snapshot = await databaseReference.child(id).get();
      if (snapshot.exists) {
        return UserLocation.fromData(
            Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserLocation?> readSingle2(String id) async {
    try {
      final snapshot = await databaseReference.child(id).get();
      if (snapshot.exists) {
        return UserLocation.fromData(
            Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  void updateData(UserLocation userLocation) async {
    try {
      final snapshot = await databaseReference.child(userLocation.id).get();
      if (snapshot.exists) {
        await databaseReference
            .child(userLocation.id)
            .update(userLocation.toJson());
      } else {
        write(userLocation);
      }
    } catch (e) {
      rethrow;
    }
  }

  void deleteData(String id) async {
    try {
      await databaseReference.child(id).remove();
      print('Child of child node removed successfully');
    } catch (e) {
      rethrow;
    }
  }

  double distance(LatLng cordinate, LatLng currentLocation) {
    double distance = math.sqrt(
        math.pow((cordinate.latitude - currentLocation.latitude), 2) +
            (math.pow((cordinate.longitude - currentLocation.longitude), 2)));
    return distance;
  }
}
