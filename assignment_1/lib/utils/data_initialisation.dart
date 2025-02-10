import '../models/person.dart';
import '../models/vehicle.dart';
import '../models/parking_space.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../repositories/parking_space_repository.dart';

void initializeData(
  PersonRepository personRepo,
  VehicleRepository vehicleRepo,
  ParkingSpaceRepository parkingSpaceRepo,
) {
  // Add default Persons
  var person1 = Person('Alice', 1234567890);
  var person2 = Person('Bob', 2345678901);
  var person3 = Person('Charlie', 3456789012);
  personRepo.addPerson(person1);
  personRepo.addPerson(person2);
  personRepo.addPerson(person3);

  // Add default ParkingSpaces
  var parkingSpace1 = Parkingspace('1', 'Main Street 1', 10);
  var parkingSpace2 = Parkingspace('2', 'Second Street 2', 15);
  var parkingSpace3 = Parkingspace('3', 'Third Avenue 3', 20);
  parkingSpaceRepo.addParkingSpace(parkingSpace1);
  parkingSpaceRepo.addParkingSpace(parkingSpace2);
  parkingSpaceRepo.addParkingSpace(parkingSpace3);

  // Add default Vehicles
  var vehicle1 = Vehicle('ABC123', person1);
  var vehicle2 = Vehicle('XYZ789', person2);
  var vehicle3 = Vehicle('DEF456', person3);
  vehicleRepo.addVehicle(vehicle1);
  vehicleRepo.addVehicle(vehicle2);
  vehicleRepo.addVehicle(vehicle3);
}