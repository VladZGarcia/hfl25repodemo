import 'package:server/models/vehicle_entity.dart';
import 'package:server/repositories/file_repository.dart';
import 'package:shared/shared.dart';

class VehicleRepository extends FileRepository<VehicleEntity> {
  VehicleRepository() : super('vehicles.json');

  @override
  VehicleEntity fromJson(Map<String, dynamic> json) {
    return VehicleEntity.fromJson(json);
  }

  @override
  String idFromType(VehicleEntity item) {
    return item.id;
  }

  @override
  String simpleIdFromType(VehicleEntity item) {
    return item.registrationNumber;
  }

  @override
  Map<String, dynamic> toJson(VehicleEntity item) {
    return item.toJson();
  }

  @override
  Future<VehicleEntity> getById(String id) async {
    var vehicles = await readFile();
    for (var vehicle in vehicles) {
      if (simpleIdFromType(vehicle) == id) {
        return vehicle;
      }
    }
    throw Exception('Vehicle not found');
  }

  
  /* List<Vehicle> vehicles = [];

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    vehicles.add(vehicle);
    return vehicle;
    }

  Future<List<Vehicle>> getAll() async => vehicles;

  Future<Vehicle?> getById(String regNr) async =>vehicles
    .cast<Vehicle?>()
    .firstWhere((v) => v?.registrationNumber == regNr, orElse: () => null);
    

  Future<Vehicle> update(Vehicle vehicle) async {
    var index = vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) vehicles[index] = vehicle;
    return vehicle;
  }

  Future<Vehicle> delete(String regNr) async {
    Vehicle removedVehicle = vehicles.cast<Vehicle>().firstWhere((v) => v.registrationNumber == regNr);
    vehicles.removeWhere((v) => v.registrationNumber == regNr);
    return removedVehicle;
  } */
}
