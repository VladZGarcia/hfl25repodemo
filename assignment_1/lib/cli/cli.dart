import 'dart:io';
import '../repositories/parking_space_repository.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';
import '../repositories/parking_repository.dart';
import 'parking_commands.dart';
import 'person_commands.dart';
import 'vehicle_commands.dart';
import 'parking_space_commands.dart';

void runCLI() {
  var personRepo = PersonRepository();
  var vehicleRepo = VehicleRepository();
  var parkingRepo = ParkingRepository();
  var parkingSpaceRepo = ParkingSpaceRepository();

  while (true) {
    print('\nWellcome to the Parking App!');
    print('Select an option:');
    print('1. Handle Persons?');
    print('2. Handle Vehicles?');
    print('3. Handle Parking?');
    print('4. Handle Parking spaces?');
    print('5. Quit.');
    stdout.write('Choose alternativ (1-5): ');
    var choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        handlePersons(personRepo);
        break;
      case '2':
        handleVehicles(vehicleRepo);
        break;
      case '3':
        handleParking(parkingRepo);
        break;
      case '4':
        handleParkingSpace(parkingSpaceRepo);
        break;
      case '5':
        exit(0);
      default:
        print('\nNot valid, try again.');
    }
  }
}
