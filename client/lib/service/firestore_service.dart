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

  final CollectionReference notifyCollectionRef =
      FirebaseFirestore.instance.collection("notificattions");

  Future createDriver(ClienT client) async {
    try {
      await clientsCollectionRef.doc(client.id).set(client.toJson());
    } catch (e) {
      return e.toString();
    }
  }

  Future<ClienT> getUser(String uid) async {
    try {
      var clientData = await clientsCollectionRef.doc(uid).get();
      print(clientData.data());
      return ClienT.fromData(clientData.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getUsertoken(String uid) async {
    try {
      var clientData = await clientsCollectionRef.doc('$uid/token').get();
      return clientData.toString();
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
      await clientsCollectionRef
          .doc(uid)
          .update({"isAvailable": value})
          .then((value) => debugPrint("User Updated"))
          .catchError((error) => debugPrint("Failed to update user: $error"));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getClienttoken(String uid) async {
    try {
      var clientData = await clientsCollectionRef.doc('$uid/token').get();
      return clientData.toString();
    } catch (e) {
      rethrow;
    }
  }

  Future<Driver> getDrivers(String uid) async {
    try {
      var driverData = await driversCollectionRef.doc(uid).get();
      return Driver.fromData(driverData.data() as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
