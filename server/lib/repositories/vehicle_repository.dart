import 'package:shared/shared.dart';

class VehicleRepository {
  List<Vehicle> vehicles = [];

  Future<void> addVehicle(Vehicle vehicle) async => vehicles.add(vehicle);
  Future<List<Vehicle>> getAll() async => vehicles;
  Future<Vehicle?> getById(String regNr) async => vehicles.cast<Vehicle?>().firstWhere((v) => v?.registrationNumber == regNr, orElse: () => null);
  Future<void> update(Vehicle vehicle) async {
    var index = vehicles.indexWhere((v) => v.registrationNumber == vehicle.registrationNumber);
    if (index != -1) vehicles[index] = vehicle;
  }
  Future<void> delete(String regNr) async => vehicles.removeWhere((v) => v.registrationNumber == regNr);
}