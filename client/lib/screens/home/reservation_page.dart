import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String uid;
  ReservationPage({super.key, required this.data, required this.uid});
  List tmp = [];

  reserver() async {
    if (data["inscrit"].contains(uid)) {
      Fluttertoast.showToast(msg: "You already reserved in this Trip");
    } else {
      tmp.add(uid);
      await FirebaseFirestore.instance
          .collection("Trips")
          .doc(data['tripid'])
          .update({
        "inscrit": FieldValue.arrayUnion(tmp),
        "placesleft": FieldValue.increment(-1)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: data['placesleft'] != 0
            ? ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green[700]),
                ),
                onPressed: () {
                  reserver();
                },
                child: Text('Reserver'),
              )
            : ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey)),
                onPressed: () {
                },
                child: Text('No places left'),
              ),
      ),
      body: Container(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${data['Station']} -----> ${data['distination']}"),
            Text(
                "heure de départ: ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateDipart']))}"),
            Text(
                "l'heure d'arrivé: ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateArrive']))}"),
            Text("Le nombre total de passagers: ${data['num_places']}"),
            Text("Le nombre de places restantes: ${data['placesleft']}")
          ],
        ),
      )),
    );
  }
}
