import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class MyTripINFO extends StatefulWidget {
  final Map<String, dynamic> data;
  MyTripINFO({super.key, required this.data, required id});

  @override
  State<MyTripINFO> createState() => _MyTripINFOState();
}

class _MyTripINFOState extends State<MyTripINFO> {
  bool _isready = false;
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    getpassengersdata();
  }

  readdata(List list) async {
    await FirebaseFirestore.instance
        .collection('clients')
        .where(FieldPath.documentId, whereIn: list)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        names.add(doc["name"] + "  " + doc['phone']);
      });
      setState(() {});
    });
  }

  getpassengersdata() async {
    var chunks = [];
    int chunkSize = 10;
    for (var i = 0; i < widget.data['inscrit'].length; i += chunkSize) {
      chunks.add(widget.data['inscrit'].sublist(
          i,
          i + chunkSize > widget.data['inscrit'].length
              ? widget.data['inscrit'].length
              : i + chunkSize));
    }

    for (var i = 0; i < chunks.length; i++) {
      readdata(chunks[i]);
    }

    setState(() {
      _isready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
      ),
      body: _isready
          ? Container(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "${widget.data['Station']} -----> ${widget.data['distination']}"),
                    Text(
                        "heure de départ: ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.data['DateDipart']))}"),
                    Text(
                        "l'heure d'arrivé: ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.data['DateArrive']))}"),
                    Text(
                        "Le nombre total de passagers: ${widget.data['num_places']}"),
                    Text(
                        "Le nombre de places restantes: ${widget.data['placesleft']}"),
                    SizedBox(
                      height: 20,
                    ),
                    Text("reserved passengers:"),
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: names.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: Text(names[index]),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
