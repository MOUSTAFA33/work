import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

const _emojis = ['😞', '🙁', '😐', '🙂', '😃'];
const opinion = [
  'خدمة سيئة',
  'غير راض',
  'متوسط',
  'راض عن الخدمة',
  "راض للغاية"
];

class ReviewDriver extends StatefulWidget {
  final String driverid;
  final String clientid;
  ReviewDriver({super.key, required this.driverid, required this.clientid});

  @override
  State<ReviewDriver> createState() => _ReviewDriverState();
}

class _ReviewDriverState extends State<ReviewDriver> {
  String comment = "";

  sendreview(
      String comment, double rating, String clientid, String driverid) async {
    var now = new DateTime.now().millisecondsSinceEpoch;
    final Collref = await FirebaseFirestore.instance.collection("drivers");
    Collref.doc(driverid)
        .collection("reviews")
        .add({
          'comment': comment,
          'rating': rating,
          'clientid': clientid,
          'driverid': driverid,
          "time": now,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  double _value = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.rate_review,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'قيم السائق',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${_emojis[_value.toInt()]}',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Text(
                '${opinion[_value.toInt()]}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(_emojis[0], softWrap: true),
                      Expanded(
                        child: Slider(
                          thumbColor: Colors.green,
                          value: _value,
                          //label: _emojis[_value.toInt()],
                          min: 0.0,
                          max: 4.0,
                          divisions: 4,

                          onChangeStart: (double value) {
                            print('Start value is ' + value.toString());
                          },
                          onChangeEnd: (double value) {
                            print('Finish value is ' + value.toString());
                          },
                          onChanged: (double value) {
                            print(value);
                            setState(() {
                              _value = value;
                            });
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.black45,
                        ),
                      ),
                      Text(
                        _emojis[4],
                        softWrap: true,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'عبر عن رأيك',
                      hintTextDirection: TextDirection.rtl),
                  onChanged: (value) {
                    comment = value;
                    print(comment);
                  },
                ),
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        sendreview(comment, _value + 1, widget.clientid,
                            widget.driverid);
                        Navigator.pop(context);
                      },
                      child: const Text('إرسال'),
                    ),
                  ],
                ),
              ),
            ]),
      )),
    );
  }
}
