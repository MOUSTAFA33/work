import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  final String name;
  final LatLng coordinates;

  Place({required this.name, required this.coordinates});
}

final List<Place> places = [
    Place(name: 'مستشفى إليزي', coordinates: LatLng(26.4977336, 8.4734922)),
    Place(name: 'فندق بوناقة', coordinates: LatLng(26.4981627, 8.4753274)),
    Place(name: 'دائرة إيليزي', coordinates: LatLng(26.507208, 8.4813084)),
    Place(name: 'بلدية إليزي', coordinates: LatLng(26.5060021,8.4855666)),
    Place(name: 'حي الوئام', coordinates: LatLng(26.508313,8.4833317)),
    Place(name: 'ملعب اليزي', coordinates: LatLng(26.5123122, 8.4836916)),
    Place(name: 'حي جبريل', coordinates: LatLng(26.5152753, 8.4912685)),
    Place(name: 'ثانوية مبارك الميلي إيليزي', coordinates: LatLng(26.5162617, 8.4842262)),
  ];