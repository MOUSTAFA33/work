import 'dart:async';
import 'package:driver/screens/home/timer.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomAlertDialog extends StatefulWidget {
  final String name;

  final String email;
  final String phone;
  final LatLng sourceLocation;
  final LatLng destinationLocation;

  CustomAlertDialog({
    required this.name,
    required this.email,
    required this.phone,
    required this.sourceLocation,
    required this.destinationLocation,
  });

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late AudioPlayer audioPlayer;
  late Timer timer;
  int timerValue = 7;

  @override
  void initState() {
    super.initState();
    play();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    timer.cancel();
  }

  void play() async {
    audioPlayer = AudioPlayer();
    await audioPlayer.play(
      AssetSource('sounds/tune.mp3'),
    );
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerValue > 0) {
          timerValue -= 1;
        } else {
          timer.cancel();
          audioPlayer.stop();
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.person_2,
        color: Colors.white,
        size: 64,
      ),
      backgroundColor: Colors.black45,
      title: Text(
        '${widget.name}',
        style: const TextStyle(color: Colors.white),
      ),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Email: ${widget.email}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Phone: ${widget.phone}',
              style: const TextStyle(color: Colors.white),
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            Card(
                child: ListTile(
                    leading: Icon(
                      Icons.location_pin,
                      color: Colors.red[400],
                    ),
                    title: const Text('Source Location'),
                    subtitle: Text(
                      ' ${widget.sourceLocation.toString()}',
                    ))),
            Card(
                child: ListTile(
                    leading: Icon(
                      Icons.flag,
                      color: Colors.green[400],
                    ),
                    title: const Text('Destination Location'),
                    subtitle: Text(
                      '${widget.destinationLocation.toString()}',
                    ))),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            Center(
                child: Text(
              '$timerValue Sec',
              style: TextStyle(color: Colors.white, fontSize: 20),
            )),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                audioPlayer.stop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Accept'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                audioPlayer.stop();
                Navigator.of(context).pop(false);
              },
              child: const Text('Refuse'),
            ),
          ],
        ),
      ],
    );
  }
}
