import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/models/long_trip.dart';
import 'package:driver/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/Trip_lists.dart';
import 'Long_tripinfo.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});
  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  AuthService authService = AuthService();
  String uid = "";
  String station = "Station illizi";
  String distination = "illizi";
  int datedepart = 0;
  int datearrive = 0;
  int numplaces = 0;
  TextEditingController descriptionFieldController = TextEditingController();
  bool _isready = false;
  Stream<QuerySnapshot>? Trips_stream;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    getDriveruid();
  }

  getDriveruid() async {
    uid = await authService.getCurrentUserUid();
    setState(() {});
    get_myLongTrips();
  }

  get_myLongTrips() async {
    if (uid != "") {
      Trips_stream = await FirebaseFirestore.instance
          .collection("Trips")
          .where("driver_id", isEqualTo: uid)
          .snapshots();
      setState(() {
        _isready = true;
      });
      print(Trips_stream!.length);
    }
  }

  Create_LongTrip() {
    final document = FirebaseFirestore.instance.collection("Trips").doc();

    LongTrip tmpTrip = LongTrip(document.id, uid, station, distination,
        datedepart, datearrive, numplaces, descriptionFieldController.text);

    document.set(tmpTrip.toJson()).then((value) {
      print(document.id);
      print("Success!");
      Fluttertoast.showToast(msg: "Trip created succesfully");
    }).catchError((e) {
      print(e);
      Fluttertoast.showToast(msg: e);
    });
  }

  delete_Trip(String docID) {
    FirebaseFirestore.instance.collection("Trips").doc(docID).delete().then(
          (doc) =>
              Fluttertoast.showToast(msg: "Trip Has been deleted succesfully"),
          onError: (e) => print("Error updating document $e"),
        );
    ;
  }

  dateTimePickerWidget(BuildContext context, int tmp) {
    var date = new DateTime.now();
    return DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: new DateTime(date.year, date.month + 1, date.day),
        onChanged: (time) {
      setState(() {});
    }, onConfirm: (date) {
      if (tmp == 0) {
        setState(() {
          datedepart = date.millisecondsSinceEpoch;
        });
      } else if (tmp == 1) {
        setState(() {
          datearrive = date.millisecondsSinceEpoch;
        });
      }
    setState(() {});
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  @override
  Widget build(BuildContext context) {
    // Stations
    Widget stationsfield = StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return DropdownButton<String>(
            hint: Text("Station"),
            icon: Icon(Icons.location_on),
            value: station,
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
      }
    );

    // Distination
    Widget distinationsfield = StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return DropdownButton<String>(
            hint: Text("Distination"),
            icon: Icon(Icons.location_on_outlined),
            value: distination,
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
      }
    );

    final DatedepartField = TextButton(
        onPressed: () {
          dateTimePickerWidget(context, 0);
        },
        child: datedepart != 0
            ? Text(
                DateTime.fromMillisecondsSinceEpoch(datedepart).toString(),
                style: TextStyle(color: Colors.green),
              )
            : Text('تاريخ المغادرة'));

    final DateArriveField = StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return TextButton(
            onPressed: () {
              dateTimePickerWidget(context, 1);
            },
            child: datearrive != 0
                ? Text(
                    DateTime.fromMillisecondsSinceEpoch(datearrive).toString(),
                    style: TextStyle(color: Colors.green),
                  )
                : Text('تاريخ الوصول'));
      }
    );

    Future newTripdialog(BuildContext context) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("محطة المغادرة"),
                      stationsfield,
                      Text("محطة الوصول"),
                      distinationsfield,
                      Text("موعد المغادرة"),
                      DatedepartField,
                      Text("موعد الوصول"),
                      DateArriveField,
                      Text("عدد الأماكن"),
                      TextFormField(
                        onChanged: (num) {
                          numplaces = int.parse(num);
                        },
                        decoration: const InputDecoration(
                          labelText: 'عدد الأماكن الباقية',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      Text("الوصف"),
                      TextField(
                        minLines: 3,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        controller: descriptionFieldController,
                        decoration:
                            InputDecoration(hintText: "أي معلومات اضافية"),
                      ),
                    ],
                  ),
                );
              },
            ), // here
            actions: [
              ElevatedButton(
                  child: Text('إلغاء'),
                  style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red[800])),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue[800])),
                      child: Text('إنشاء'),
                      onPressed: () {
                        if (uid != "" &&
                            station != "" &&
                            distination != "" &&
                            datedepart != 0 &&
                            datearrive != 0 &&
                            numplaces != 0) {
                          Create_LongTrip();
                          datedepart = 0;
                          datearrive = 0;
                          confirmed = false;
                          station = "";
                          distination = "";
                          numplaces = 0;
                          descriptionFieldController.text = "";
                        }
                        Navigator.of(context).pop();
                      })
            ],
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        child: _isready
            ? StreamBuilder<QuerySnapshot>(
                stream: Trips_stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text("Loading"));
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                        onTap: (){
                          Navigator.push((context),
                  MaterialPageRoute(builder: (context) => MyTripINFO(id: data['tripid'], data: data,)));
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text(
                                        "are you sure you want to delete this trip?"),
                                    actions: [
                                      ElevatedButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                      ElevatedButton(
                                          child: Text('Delete'),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.red)),
                                          onPressed: () {
                                            delete_Trip(data['tripid']);
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  );
                                });
                          },
                        ),  
                        title: Text(
                            "${data['Station']} -----> ${data['distination']}"),
                        subtitle: Text(
                            "${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateDipart']))} \n ${DateFormat('MM/dd/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(data['DateArrive']))} \n ${data['num_places']} places"),
                      );
                    }).toList(),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
        onPressed: () {
          newTripdialog(context);
        },
      ),
    );
  }
}

// Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Station de depart"),
//                   stationsfield,
//                   Text("Station d'arrive"),
//                   distinationsfield,
//                   Text("Date de depart"),
//                   DatedepartField,
//                   Text("Date d'arrive"),
//                   DateArriveField,
//                   Text("Nombre des place"),
//                   TextFormField(
//                     onChanged: (num) {
//                       numplaces = int.parse(num);
//                     },
//                     decoration: const InputDecoration(
//                       labelText: 'Number of places',
//                     ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   Text("Description"),
//                   TextField(
//                     minLines: 3,
//                     maxLines: 6,
//                     keyboardType: TextInputType.multiline,
//                     controller: descriptionFieldController,
//                     decoration:
//                         InputDecoration(hintText: "Text Field in Dialog"),
//                   ),
//                 ],
//               );
