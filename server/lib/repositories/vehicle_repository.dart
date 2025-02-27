import 'package:shared/shared.dart';

class VehicleRepository {
  List<Vehicle> vehicles = [];

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
  }
}