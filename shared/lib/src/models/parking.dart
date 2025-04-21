import 'package:intl/intl.dart';
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

  /// Formats a DateTime object to a string in the format HH:MM.
  String formatTime(DateTime? dateTime) {
    final hours = dateTime?.hour.toString().padLeft(2, '0');
    final minutes = dateTime?.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
}
