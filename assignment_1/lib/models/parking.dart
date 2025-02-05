import '../models/vehicle.dart';
import 'parking_space.dart';

class Parking {
  Vehicle vehicle;
  Parkingspace parkingSpace;
  DateTime startTime;
  DateTime? endTime;

  Parking(this.vehicle, this.parkingSpace, this.startTime, this.endTime);
}
