import 'package:client/screens/home/reservation_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

class MytripsList extends StatefulWidget {
  final String id;
  const MytripsList({super.key, required this.id});

  @override
  State<MytripsList> createState() => _MytripsListState();
}

class _MytripsListState extends State<MytripsList> {
  Stream<QuerySnapshot>? Trips_stream;
  bool _isready = false;

  @override
  void initState() {
    super.initState();
    getMyTrips();
  }

  getMyTrips() async {
    final Collref = await FirebaseFirestore.instance.collection("Trips");
    Trips_stream =
        Collref.where("inscrit", arrayContains: widget.id).snapshots();
    setState(() {
      _isready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرحلات المسجلة"),
      ),
      body: SingleChildScrollView(
        child: _isready
            ? StreamBuilder<QuerySnapshot>(
                stream: Trips_stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }
                  if (snapshot.data == null) {
                    return Center(child: Text("No trips are available"));
                  } else {
                    return Expanded(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          if (!snapshot.hasData) {
                            return Center(
                                child: Text("No trips are available"));
                          } else {
                            return Padding(
                              padding:
                                  EdgeInsetsDirectional.symmetric(vertical: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
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
                                            builder: (c) => ReservationPage(
                                                  data: data,
                                                  uid: widget.id,
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
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
