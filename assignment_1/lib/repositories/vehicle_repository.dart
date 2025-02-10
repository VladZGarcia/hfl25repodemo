import '../models/vehicle.dart';

class VehicleRepository {
  List<Vehicle> vehicles = [];

  void addVehicle(Vehicle vehicle) => vehicles.add(vehicle);
  List<Vehicle> getAll() => vehicles;
  Vehicle? getById(String regNr) => vehicles.cast<Vehicle?>().firstWhere((v) => v?.registrationNumber == regNr, orElse: () => null);
  void update(Vehicle vehicle) {
    var index = vehicles.indexWhere((v) => v.registrationNumber == vehicle.registrationNumber);
    if (index != -1) vehicles[index] = vehicle;
  }
  void delete(String regNr) => vehicles.removeWhere((v) => v.registrationNumber == regNr);
}