import '../models/person.dart';
import '../models/vehicle.dart';
import '../models/parking_space.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../repositories/parking_space_repository.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

void initializeData(
  PersonRepository personRepo,
  VehicleRepository vehicleRepo,
  ParkingSpaceRepository parkingSpaceRepo,
) {
  // Add default Persons
  var person1 = Person(uuid.v4(),'Alice', 1234567890);
  var person2 = Person(uuid.v4(),'Bob', 2345678901);
  var person3 = Person(uuid.v4(),'Charlie', 3456789012);
  personRepo.addPerson(person1);
  personRepo.addPerson(person2);
  personRepo.addPerson(person3);

  // Add default ParkingSpaces
  var parkingSpace1 = Parkingspace(uuid.v4(),'1', 'Main Street 1', 10);
  var parkingSpace2 = Parkingspace(uuid.v4(),'2', 'Second Street 2', 15);
  var parkingSpace3 = Parkingspace(uuid.v4(),'3', 'Third Avenue 3', 20);
  parkingSpaceRepo.addParkingSpace(parkingSpace1);
  parkingSpaceRepo.addParkingSpace(parkingSpace2);
  parkingSpaceRepo.addParkingSpace(parkingSpace3);

  // Add default Vehicles
  var vehicle1 = Vehicle(uuid.v4(),'ABC123', person1);
  var vehicle2 = Vehicle(uuid.v4(),'XYZ789', person2);
  var vehicle3 = Vehicle(uuid.v4(),'DEF456', person3);
  vehicleRepo.addVehicle(vehicle1);
  vehicleRepo.addVehicle(vehicle2);
  vehicleRepo.addVehicle(vehicle3);
}