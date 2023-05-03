import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/Trip_lists.dart';
import '../../service/auth_service.dart';
import 'reservation_page.dart';

class LongTrip extends StatefulWidget {
  const LongTrip({super.key});

  @override
  State<LongTrip> createState() => _LongTripState();
}

class _LongTripState extends State<LongTrip> {
  AuthService authService = AuthService();
  String uid = "";
  String station = "";
  String distination = "";
  bool _isready = false;
  bool _searching = false;
  Stream<QuerySnapshot>? Trips_stream;
  Query<Map<String, dynamic>>? query;

  @override
  void initState() {
    super.initState();
    getDriveruid();
  }

  getDriveruid() async {
    uid = await authService.getCurrentUserUid();
    setState(() {});
  }

  searchTrip() async {
    _searching = true;
    final Collref = await FirebaseFirestore.instance.collection("Trips");

    if (station != "Any" && distination != "Any") {
      Trips_stream = Collref.where("Station", isEqualTo: station)
          .where("distination", isEqualTo: distination)
          .snapshots();
    }

    if (station == "Any" && distination == "Any") {
      Trips_stream = Collref.snapshots();
    }

    if (station != "Any" && distination == "Any") {
      Trips_stream = Collref.where("Station", isEqualTo: station).snapshots();
    }

    if (station == "Any" && distination != "Any") {
      Trips_stream =
          Collref.where("distination", isEqualTo: distination).snapshots();
    }

    setState(() {
      _isready = true;
      _searching = false;
    });
    print("$station ===> $distination \t\t\t ");
  }

  @override
  Widget build(BuildContext context) {
    // Stations
    final stationsfield = DropdownButton<String>(
        hint: Text("Station"),
        icon: Icon(Icons.location_on),
        isExpanded: true,
        //value: station == "" ? "station" : station,
        onChanged: (value) {
          setState(() {
            station = value!;
          });
        },
        items: Stations.map((val) {
          return DropdownMenuItem<String>(
            value: val.toString(),
            child: Text(val),
          );
        }).toList());

    // Distination
    final distinationsfield = DropdownButton<String>(
        hint: Text("Distination"),
        icon: Icon(Icons.location_on_outlined),
        isExpanded: true,
        //value: distination == "" ? "distination" : distination,
        onChanged: (value) {
          setState(() {
            distination = value!;
          });
        },
        items: Distination.map((val) {
          return DropdownMenuItem<String>(
            value: val.toString(),
            child: Text(val),
          );
        }).toList());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            stationsfield,
            SizedBox(
              height: 5,
            ),
            distinationsfield,
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[700]),
                ),
                onPressed: () {
                  if (distination != "" && station != "") {
                    searchTrip();
                  } else {
                    Fluttertoast.showToast(
                        msg: "please dont leave empty fields");
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Search"),
                    Icon(Icons.search),
                  ],
                )),
            SingleChildScrollView(
              child: _searching
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _isready
                      ? StreamBuilder<QuerySnapshot>(
                          stream: Trips_stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Something went wrong'));
                            }
                            if (snapshot.data == null) {
                              return Center(
                                  child: Text("No trips are available"));
                            } else {
                              return Expanded(
                                child: ListView(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  children: snapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;
                                    if (!snapshot.hasData) {
                                      return Center(
                                          child:
                                              Text("No trips are available"));
                                    } else {
                                      return Padding(
                                        padding:
                                            EdgeInsetsDirectional.symmetric(
                                                vertical: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                                color: Colors.green,
                                                width: 2 // red as border color
                                                ),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (c) =>
                                                          ReservationPage(
                                                            data: data,
                                                            uid: uid,
                                                          )));
                                            },
                                            title: Text(
                                                "${data['Station']} -----> ${data['distination']}"),
                                            subtitle: Text(
                                                "${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateDipart']))} \n ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateArrive']))} \n ${data['num_places']} places"),
                                          ),
                                        ),
                                      );
                                    }
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        )
                      : SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }
}
