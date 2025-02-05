import 'dart:io';
import '../cli/person_commands.dart';
import 'package:assignment_1/repositories/person_repository.dart';
import 'package:assignment_1/repositories/vehicle_repository.dart';

void runCLI() {
  var personRepo = PersonRepository();
  var vehicleRepo = VehicleRepository();

  while (true) {
    print('Wellcome to the Parking App!');
    print('Select an option:');
    print('1. Handle Persons?');
    print('2. Handle Vehicles?');
    print('5. Quit.');
    stdout.write('Choose alternativ (1-5): ');
    var choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        handlePersons(personRepo);
        break;
      case '2':
        handleVehicles(vehicleRepo, personRepo);
        break;
      case '5':
        exit(0);
      default:
        print('Not valid, try again.');
    }
  }
}



void handleVehicles(VehicleRepository repo, PersonRepository personRepo) {
  //Todo
}
