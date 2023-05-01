import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trip {
  final LatLng? source;
  final LatLng? distenation;

  Trip(this.source, this.distenation);

  Trip.fromData(Map<String, dynamic> data)
      : source = LatLng(data['source'][0], data['source'][1]),
        distenation = LatLng(data['distenation'][0], data['distenation'][1]);

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'distenation': distenation,
    };
  }
}
