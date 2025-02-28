import 'package:shared/shared.dart';

class ParkingRepository {
  List<Parking> parkings = [];

  Future<Parking> addParking(Parking parking) async {
    parkings.add(parking);
    return parking;
    }

  Future<List<Parking>> getAll() async => parkings;

  Future<Parking?> getById(String id) async => parkings
    .cast<Parking?>()
    .firstWhere((p) => p?.id == id, orElse: () => null);

  Future<Parking> update(Parking parking) async {
    var index = parkings.indexWhere((p) => p.id == parking.id);
    if (index != -1) parkings[index] = parking;
    return parking;
  }

  Future<Parking> delete(String id) async {
    Parking removedParking = parkings.cast<Parking>().firstWhere((p) => p.id == id);
    parkings.removeWhere((p) => p.id == id);
    return removedParking;
    }
}