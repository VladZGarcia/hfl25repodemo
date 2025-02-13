import '../models/vehicle.dart';
import 'parking_space.dart';

class Parking {
  final String id;
  Vehicle vehicle;
  Parkingspace parkingSpace;
  DateTime startTime;
  DateTime? endTime;

  Parking(this.id, this.vehicle, this.parkingSpace, this.startTime, this.endTime);
}
