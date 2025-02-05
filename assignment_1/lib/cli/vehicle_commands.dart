import 'dart:io';
import '../models/vehicle.dart';
import '../repositories/person_repository.dart';
import '../repositories/vehicle_repository.dart';

void handleVehicles(VehicleRepository repo, PersonRepository personRepo) {
  while (true) {
    print('\nVehicle handling. How can I help you?');
    print('1. Create vehicle.');
    print('2. Show all vehicles.');
    print('3. Update vehicle.');
    print('4. Delete vehicle.');
    print('5. Back to Main menu.');
    stdout.write('Choose alternative (1-5): ');

    var choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        _createVehicle(repo);
        break;
      case '2':
        _showAllVehicle(repo);
        break;
      case '3':
        _updateVehicle(repo);
        break;
      case '4':
        _deleteVehicle(repo);
        break;
      case '5':
        return;
      default:
        print('Not valid, try again.');
    }
  }
}

void _createVehicle(VehicleRepository repo) {
  stdout.write('Enter RegNr: ');
  var regNr = stdin.readLineSync();
 /*  stdout.write('Enter owner ID: ');
  var owner = stdin.readLineSync(); */

  if (regNr != null) {
    var vehicle = Vehicle(regNr);
    repo.addVehicle(vehicle);
    print('Vehicle created: ${vehicle.registrationNumber}');
  } else {
    print('Invalid input, try again.');
  }
}

void _showAllVehicle(VehicleRepository repo) {
  var vehicles = repo.getAll();
  if (vehicles.isEmpty) {
    print('No vehicles found!');
  } else {
    print('List of vehicles:');
    for (var vehicle in vehicles) {
      print('RegNr: ${vehicle.registrationNumber}');
    }
  }
}

void _updateVehicle(VehicleRepository repo) {
  stdout.write('Input vehicle RegNr to update: ');
  var regNr = stdin.readLineSync();
  var vehicle = repo.getById(regNr ?? '');

  if (vehicle != null) {
    stdout.write('New RegNr (current RegNr: ${vehicle.registrationNumber}):');
    var newRegNr = stdin.readLineSync();
    if (newRegNr != null && newRegNr.isNotEmpty) {
      vehicle.registrationNumber = newRegNr;
      repo.update(vehicle);
      print('Person updated: ${vehicle.registrationNumber}');
    } else {
      print('RegNr not valid.');
    }
  } else {
    print('Vehicle with RegNr $regNr not found.');
  }
}

void _deleteVehicle(VehicleRepository repo) {
  stdout.write('Input RegNr for vehicle to delete: ');
  var regNr = stdin.readLineSync();
  var vehicle = repo.getById(regNr ?? '');

  if (vehicle != null) {
    repo.delete(regNr ?? '');
    print('Vehicle deleted: ${vehicle.registrationNumber}');
  } else {
    print('Vehicle with RegNr $regNr not found');
  }
}
