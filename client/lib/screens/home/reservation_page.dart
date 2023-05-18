import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String uid;
  ReservationPage({super.key, required this.data, required this.uid});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List tmp = [];
  List annulertmp = [];
  bool _isready = false;
  bool _isreserved = false;

  @override
  void initState() {
    super.initState();
    isalreadyreserved();
  }

  isalreadyreserved() {
    if (widget.data["inscrit"].contains(widget.uid)) {
      _isreserved = true;
    }
    setState(() {
      _isready = true;
    });
  }

  reserver() async {
    tmp.add(widget.uid);
    await FirebaseFirestore.instance
        .collection("Trips")
        .doc(widget.data['tripid'])
        .update({
      "inscrit": FieldValue.arrayUnion(tmp),
      "placesleft": FieldValue.increment(-1)
    });
  }

  annulerreservervation() async {
    print("start");
    await FirebaseFirestore.instance
        .collection("Trips")
        .doc(widget.data['tripid'])
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        // print('Document exists on the database');
        // print(documentSnapshot.data());
        annulertmp = documentSnapshot.get('inscrit');
        print(annulertmp);

        annulertmp.removeWhere((item) => item == widget.uid);
        print(annulertmp);

        await FirebaseFirestore.instance
        .collection("Trips")
        .doc(widget.data['tripid'])
        .update({
      "inscrit": annulertmp,
    });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        child: !_isreserved
            ? widget.data['placesleft'] != 0
                ? ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.green[700]),
                    ),
                    onPressed: () {
                      reserver();
                    },
                    child: Text('Reserver'),
                  )
                : ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey)),
                    onPressed: () {},
                    child: Text('No places left'),
                  )
            : ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red[700]),
                ),
                onPressed: () {
                  annulerreservervation();
                },
                child: Text('Annuler reservation'),
              ),
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
                        "Le nombre de places restantes: ${widget.data['placesleft']}")
                  ],
                ),
              ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
