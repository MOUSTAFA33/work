import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../models/notifications.dart';

class FixedAlertDialog extends StatefulWidget {
  const FixedAlertDialog({Key? key}) : super(key: key);
  static final GlobalKey<State<StatefulWidget>> dialogKey =
      GlobalKey<State<StatefulWidget>>();

  @override
  State<FixedAlertDialog> createState() => _FixedAlertDialogState();
}

class _FixedAlertDialogState extends State<FixedAlertDialog> {
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        key: FixedAlertDialog.dialogKey, // Use the GlobalKey here
        content: SingleChildScrollView(
            child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 15,
              ),
              Text("waiting for the driver's response ...",
                  textAlign: TextAlign.center)
            ],
          ),
        )),
      ),
    );
  }
}
