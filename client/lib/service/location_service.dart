import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as locations;

import '../models/constants.dart';

class LocationService {
  locations.Location location = locations.Location();
  Completer<GoogleMapController> controller = Completer();

  Future<LatLng> getCurrentLoc() async {
    bool serviceEnabled;
    locations.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception();
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == locations.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != locations.PermissionStatus.granted) {
        throw Exception();
      }
    }

    locations.LocationData myLocation1 = await location.getLocation();

    return LatLng(myLocation1.latitude!, myLocation1.longitude!);
  }

  Future<void> animateCameraPos(LatLng myLocation) async {
    final GoogleMapController futureController = await controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(myLocation.latitude, myLocation.longitude),
      zoom: 15.00,
    );
    futureController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> getLocationFromPlaceId(String placeId) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: Constants.apiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(placeId);

    animateCameraPos(LatLng(detail.result.geometry!.location.lat,
        detail.result.geometry!.location.lng));
  }

  Future<BitmapDescriptor> createBitmapDescriptorFromIcon(
    IconData iconData, {
    double size = 96,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final TextStyle textStyle = TextStyle(
      fontFamily: 'MaterialIcons',
      fontSize: size,
      color: Colors.black,
    );
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: textStyle,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(0, (size - textPainter.height) / 2),
    );
    final img = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Marker getMarker(theLocation, theIcon, theTitle) {
    print('put  marker ');

    return Marker(
      markerId: MarkerId(theLocation!.toString()),
      icon: theIcon,
      // icon: _locationIcon,
      position: theLocation!,
      infoWindow: InfoWindow(
          title: theTitle,
          snippet: "${theLocation?.latitude}, ${theLocation?.longitude}"),
    );
  }
}
