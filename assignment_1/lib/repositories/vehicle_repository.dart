import '../models/vehicle.dart';

class VehicleRepository {
  List<Vehicle> vehicles = [];

  void add(Vehicle vehicle) => vehicles.add(vehicle);
  List<Vehicle> getAll() => vehicles;
  Vehicle? getById(String regNr) => vehicles.firstWhere((v) => v.registrationNumber == regNr, orElse: () => throw Exception('Vehicle not found'));
  void update(Vehicle vehicle) {
    var index = vehicles.indexWhere((v) => v.registrationNumber == vehicle.registrationNumber);
    if (index != -1) vehicles[index] = vehicle;
  }
  void delete(String regNr) => vehicles.removeWhere((v) => v.registrationNumber == regNr);
}