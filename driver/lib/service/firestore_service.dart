// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//
// import '../models/car_info.dart';
// import '../models/client.dart';
import '../models/client.dart';
import '../models/driver.dart';

class FirestoreService {
  final CollectionReference driversCollectionRef =
      FirebaseFirestore.instance.collection("drivers");
  final CollectionReference clientsCollectionRef =
      FirebaseFirestore.instance.collection("clients");
  final CollectionReference carsCollectionRef =
      FirebaseFirestore.instance.collection("cars");
  final CollectionReference notifyCollectionRef =
      FirebaseFirestore.instance.collection("notificattions");

  Future createDriver(Driver driver) async {
    try {
      await driversCollectionRef.doc(driver.id).set(driver.toJson());
    } catch (e) {
      return e.toString();
    }
  }

  Future<Driver> getUser(String uid) async {
    try {
      var driverData = await driversCollectionRef.doc(uid).get();
      return Driver.fromData(driverData.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUsertoken(String uid) async {
    try {
      var driverData = await driversCollectionRef.doc('$uid/token').get();
      return driverData.toString();
    } catch (e) {
      rethrow;
    }
  }

  void OnUser(bool val, String uid) async {
    try {
      String value;
      if (val) {
        value = "yes";
      } else {
        value = "no";
      }
      debugPrint(uid);
      await driversCollectionRef
          .doc(uid)
          .update({"isAvailable": value})
          .then((value) => debugPrint("User Updated"))
          .catchError((error) => debugPrint("Failed to update user: $error"));
    } catch (e) {
      rethrow;
    }
  }

  Future<ClienT> getClient(String uid) async {
    try {
      var driverData = await clientsCollectionRef.doc(uid).get();
      return ClienT.fromData(driverData.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getClientToken(String uid) async {
    try {
      var driverData = await clientsCollectionRef.doc('$uid/token').get();
      return driverData.toString();
    } catch (e) {
      rethrow;
    }
  }
  // Future createCar(CarInfo car) async {
  //   try {
  //     await carsCollectionRef.doc(car.idDriver).set(car.toJson());
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }
  // Future<CarInfo> getCarInfo(String uid) async {
  //   try {
  //     var driverData = await carsCollectionRef.doc(uid).get();
  //     return CarInfo.fromData(driverData.data() as Map<String, dynamic>);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  // Future createNotif(Client client,Driver driver) async {
  //   try {
  //     // await carsCollectionRef.doc(car.idDriver).set(car.toJson());
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }
}
