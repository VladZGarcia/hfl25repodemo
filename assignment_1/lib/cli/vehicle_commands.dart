import 'dart:io';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import 'package:assignment_1/models/person.dart';
import 'package:assignment_1/cli/cli_utils.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();
void handleVehicles(VehicleRepository repo) {
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
        print('\nNot valid, try again.');
    }
  }
}

void _createVehicle(VehicleRepository repo) {
  stdout.write('\nEnter RegNr: ');
  var regNr = stdin.readLineSync();
  stdout.write('Enter owner name: ');
  var ownerName = stdin.readLineSync();
  stdout.write('Enter owner ID: ');
  var ownerIdInput = stdin.readLineSync();
  int? ownerId = int.tryParse(ownerIdInput!);

  if (regNr != null && ownerName != null && ownerId != null) {
    var vehicle = Vehicle(uuid.v4(), regNr, Person(uuid.v4(),ownerName, ownerId));
    repo.addVehicle(vehicle);
    print('\nVehicle created: ${vehicle.registrationNumber}');
    print(
        'Owner name: ${vehicle.owner.name} Owner ID: ${vehicle.owner.personId}');
  } else {
    print('\nInvalid input, try again.');
  }
}

void _showAllVehicle(VehicleRepository repo) {
  var vehicles = repo.getAll();
  if (vehicles.isEmpty) {
    print('\nNo vehicles found!');
  } else {
    print('\nList of vehicles:');
    for (var vehicle in vehicles) {
      print('\nRegNr: ${vehicle.registrationNumber}');
      print(
          'Owner name: ${vehicle.owner.name} Owner ID: ${vehicle.owner.personId}');
    }
  }
}

void _updateVehicle(VehicleRepository repo) {
  stdout.write('\nInput vehicle RegNr to update: ');
  var regNr = stdin.readLineSync();
  var vehicle = repo.getById(regNr ?? '');

  if (vehicle != null) {
    stdout.write('New RegNr (current RegNr: ${vehicle.registrationNumber}):');
    var newRegNr = stdin.readLineSync();
    stdout.write('New Name (current name: ${vehicle.owner.name}):');
    var newName = stdin.readLineSync();
    stdout.write('New ID (current ID: ${vehicle.owner.personId}):');
    var newIdInput = stdin.readLineSync();
    int? newId = int.tryParse(newIdInput!);

    if (isValid(newRegNr) && isValid(newName) && newId != null) {
      vehicle.registrationNumber = newRegNr!;
      vehicle.owner.name = newName!;
      vehicle.owner.personId = newId;
      repo.update(vehicle);
      print('\nVehicle updated: ${vehicle.registrationNumber}');
      print('Owner name updated: ${vehicle.owner.name}');
      print('Owner ID updated: ${vehicle.owner.personId}');
    } else {
      print('\nRegNr not valid.');
    }
  } else {
    print('\nVehicle with RegNr $regNr not found.');
  }
}

void _deleteVehicle(VehicleRepository repo) {
  stdout.write('\nInput RegNr for vehicle to delete: ');
  var regNr = stdin.readLineSync();
  var vehicle = repo.getById(regNr ?? '');

  if (vehicle != null) {
    repo.delete(regNr ?? '');
    print('\nVehicle with RegNr ${vehicle.registrationNumber} deleted!');
  } else {
    print('\nVehicle with RegNr $regNr not found');
  }
}
