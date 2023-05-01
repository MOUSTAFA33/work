import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  final String id;
  final String userType;
  final LatLng myLocation;

  UserLocation(this.id, this.userType, this.myLocation);

  UserLocation.fromData(Map<String, dynamic> data)
      : id = data['id'],
        userType = data['userType'],
        myLocation = LatLng(data['lat']!, data['lng']!);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userType': userType,
      'lat': myLocation.latitude,
      'lng': myLocation.longitude
    };
  }
}
