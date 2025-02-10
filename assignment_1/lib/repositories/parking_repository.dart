import 'package:assignment_1/models/parking.dart';

class ParkingRepository {
  List<Parking> parkings = [];

  void addParking(Parking parking) => parkings.add(parking);
  List<Parking> getAll() => parkings;
  Parking? getById(String id) => parkings.cast<Parking?> ().firstWhere((p) => p?.id == id,
      orElse: () => null);
  void update(Parking parking) {
    var index = parkings.indexWhere((p) => p.id == parking.id);
    if (index != -1) parkings[index] = parking;
  }
  void delete(String id) => parkings.removeWhere((p) => p.id == id);
}