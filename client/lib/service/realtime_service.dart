import 'package:client/models/user_location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/driver.dart';
import 'firestore_service.dart';
import 'dart:math' as math;

class RealtimeService {
  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref('clients');
  DatabaseReference databaseReference2 =
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

  Future<UserLocation?> readDriver2(
      LatLng thelocation, List<String> list) async {
    double minDistance = double.infinity;
    UserLocation? closestDriver;
    List<UserLocation> userLocations = [];
    try {
      final snapshot = await databaseReference2.get();
      print(snapshot.value);
      if (snapshot.exists) {
        Map<String, dynamic> snapshotValue =
            Map<String, dynamic>.from(snapshot.value as Map);
        for (var i in snapshotValue.values.toList()) {
          Map<String, dynamic> a = Map<String, dynamic>.from(i as Map);
          UserLocation userLocation = UserLocation.fromData(a);
          if (!list.contains(userLocation.id)) {
            double dist = distance(userLocation.myLocation, thelocation);
            print(dist);
            if (dist < minDistance) {
              closestDriver = userLocation;
            }
          }
        }
      }
      return closestDriver;
    } catch (e) {
      rethrow;
    }
  }

  // Future<UserLocation?> readDriver(
  //     LatLng thelocation, List<String> list) async {
  //   double minDistance = double.infinity;
  //   UserLocation? closestDriver;
  //   List<UserLocation> userLocations = [];
  //   try {
  //     final snapshot = await databaseReference2.get();
  //     print(snapshot.value);
  //     if (snapshot.exists) {
  //       Map<String, dynamic> snapshotValue = Map<String, dynamic>.from(snapshot.value as Map);
  //       for (var i in snapshotValue.values.toList()) {
  //         Map<String, dynamic> a = Map<String, dynamic>.from(i as Map);
  //         UserLocation userLocation = UserLocation.fromData(a);
  //         double dist = distance(userLocation.myLocation, thelocation);
  //         print(dist);
  //         if (dist < minDistance) {
  //           closestDriver = userLocation;
  //         }
  //       }
  //     }
  //     return closestDriver;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<UserLocation?> readDriver(
      LatLng thelocation, List<String> list) async {
    double least_dist = 0;
    double minDistance = double.infinity;
    UserLocation? closestDriver;
    UserLocation? final_userLocation;
    List<UserLocation> userLocations = [];
    print("read Driver....................");
    try {
      final snapshot = await databaseReference2.get();
      print(snapshot.value);
      if (snapshot.exists) {
        Map<String, dynamic> snapshotValue =
            Map<String, dynamic>.from(snapshot.value as Map);
        for (var i in snapshotValue.values.toList()) {
          Map<String, dynamic> a = Map<String, dynamic>.from(i as Map);
          UserLocation userLocation = UserLocation.fromData(a);
          double dist = distance(userLocation.myLocation, thelocation);
          print(dist);

          if (least_dist == 0) {
            least_dist = dist;
            final_userLocation = userLocation;
          } else {
            if (dist < least_dist) {
              least_dist = dist;
              final_userLocation = userLocation;
            }
          }
        }
        closestDriver = final_userLocation;
        print("least :::\t\t$least_dist");
      }
      return closestDriver;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserLocation?> readSingle(UserLocation userLocation) async {
    try {
      final snapshot = await databaseReference.child(userLocation.id).get();
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
