import 'package:driver/models/trip.dart';

class Notifications {
  final String id;
  final String clientToken;
  final String driverToken;
  final Trip cordinate;
  final double prix;

  Notifications(
    this.id,
    this.clientToken,
    this.driverToken,
    this.cordinate, 
    this.prix,
  );

  Notifications.fromData(Map<String, dynamic> data)
      : id = data['id'],
        clientToken = data['clientToken'],
        driverToken = data['driverToken'],
        cordinate = Trip.fromData(data['cordinate']),
        prix = data['prix'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientToken': clientToken,
      'driverToken': driverToken,
      'cordinate': cordinate.toJson(),
      'prix': prix,
    };
  }
}