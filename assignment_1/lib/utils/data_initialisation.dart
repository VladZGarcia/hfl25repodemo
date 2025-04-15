import 'package:shared/shared.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../repositories/parking_space_repository.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> initializeData(
  PersonRepository personRepo,
  VehicleRepository vehicleRepo,
  ParkingSpaceRepository parkingSpaceRepo,
) async{
  // Add default Persons
  var person1 = Person(id: uuid.v4(),name:'Alice', personId: 1234567890);
  var person2 = Person(id: uuid.v4(),name:'Bob', personId:2345678901);
  var person3 = Person(id: uuid.v4(), name:'Charlie', personId:3456789012);
  await personRepo.addPerson(person1);
  await personRepo.addPerson(person2);
  await personRepo.addPerson(person3);

  // Add default ParkingSpaces
  var parkingSpace1 = Parkingspace(uuid.v4(),'1', 'Main Street 1', 10);
  var parkingSpace2 = Parkingspace(uuid.v4(),'2', 'Second Street 2', 15);
  var parkingSpace3 = Parkingspace(uuid.v4(),'3', 'Third Avenue 3', 20);
  await parkingSpaceRepo.addParkingSpace(parkingSpace1);
  await parkingSpaceRepo.addParkingSpace(parkingSpace2);
  await parkingSpaceRepo.addParkingSpace(parkingSpace3);

  // Add default Vehicles
  var vehicle1 = Vehicle(uuid.v4(),'ABC123', person1);
  var vehicle2 = Vehicle(uuid.v4(),'XYZ789', person2);
  var vehicle3 = Vehicle(uuid.v4(),'DEF456', person3);
  await vehicleRepo.addVehicle(vehicle1);
  await vehicleRepo.addVehicle(vehicle2);
  await vehicleRepo.addVehicle(vehicle3);
}