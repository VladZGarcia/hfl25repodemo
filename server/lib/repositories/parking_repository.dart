import 'package:shared/shared.dart';

class ParkingRepository {
  List<Parking> parkings = [];

  Future<void> addParking(Parking parking) async => parkings.add(parking);
  Future<List<Parking>> getAll() async => parkings;
  Future<Parking?> getById(String id) async => parkings.cast<Parking?> ().firstWhere((p) => p?.id == id,
      orElse: () => null);
  Future<void> update(Parking parking) async {
    var index = parkings.indexWhere((p) => p.id == parking.id);
    if (index != -1) parkings[index] = parking;
  }
  Future<void> delete(String id) async => parkings.removeWhere((p) => p.id == id);
}