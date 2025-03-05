import 'package:server/repositories/file_repository.dart';
import 'package:shared/shared.dart';

class VehicleRepository extends FileRepository<Vehicle> {
  VehicleRepository() : super('vehicles.json');

  @override
  Vehicle fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return Vehicle.fromJson(json);
  }

  @override
  String idFromType(Vehicle item) {
    // TODO: implement idFromType
    return item.id;
  }

  @override
  String simpleIdFromType(Vehicle item) {
    // TODO: implement personIdFromType
    return item.registrationNumber;
  }

  @override
  Map<String, dynamic> toJson(Vehicle item) {
    // TODO: implement toJson
    return item.toJson();
  }

  @override
  Future<Vehicle> getById(String id) async {
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
