import 'package:google_maps_flutter/google_maps_flutter.dart';

class LongTrip {
  final String Tripid;
  final String driver_id;
  final String Station;
  final String distination;
  final int DateDepart;
  final int DateArrive;
  final int num_places;
  final String description;
  List inscrit = [];

  LongTrip(this.Tripid, this.driver_id, this.Station, this.distination,
      this.DateDepart, this.DateArrive, this.num_places, this.description);

  Map<String, dynamic> toJson() {
    return {
      'tripid': Tripid,
      'driver_id': driver_id,
      'Station': Station,
      'distination': distination,
      'DateDipart': DateDepart,
      'DateArrive': DateArrive,
      'num_places': num_places,
      'placesleft': num_places,
      'description': description,
      'inscrit': inscrit,
    };
  }
}
