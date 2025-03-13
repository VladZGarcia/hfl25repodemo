import 'package:server/models/parking_entity.dart';
import 'package:server/repositories/file_repository.dart';
import 'package:shared/shared.dart';

class ParkingRepository extends FileRepository<ParkingEntity> {
  ParkingRepository() : super('parkings.json');

  @override
  ParkingEntity fromJson(Map<String, dynamic> json) {
    return ParkingEntity.fromJson(json);
  }

  @override
  String idFromType(ParkingEntity item) {
    return item.id;
  }

  @override
  String simpleIdFromType(ParkingEntity item) {
    return item.vehicleId;
  }

  @override
  Map<String, dynamic> toJson(ParkingEntity item) {
    return item.toJson();
  }

  @override
  Future<ParkingEntity> getById(String id) async {
    var parkings = await readFile();
    try {
      return parkings.firstWhere((parking) => simpleIdFromType(parking) == id);
    } catch (e) {
      throw Exception('Parking with ID: "$id" not found');
    }
  }
  
  /* List<Parking> parkings = [];

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
    } */
}