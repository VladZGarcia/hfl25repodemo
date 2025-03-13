import '../models/vehicle.dart';
import 'parking_space.dart';

class Parking {
  final String id;
  Vehicle vehicle;
  Parkingspace parkingSpace;
  DateTime startTime;
  DateTime? endTime;

  Parking(this.id, this.vehicle, this.parkingSpace, this.startTime, this.endTime);

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      json['id'],
      Vehicle.fromJson(json['vehicle']),
      Parkingspace.fromJson(json['parkingSpace']),
      DateTime.parse(json['startTime']),
      json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }
  Map<String, dynamic > toJson() {
    return {
      'id': id,
      'vehicle': vehicle.toJson(),
      'parkingSpace': parkingSpace.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}
