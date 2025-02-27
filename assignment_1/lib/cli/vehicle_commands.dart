import 'dart:io';
import 'package:shared/shared.dart';
import '../repositories/vehicle_repository.dart';
import 'package:assignment_1/cli/cli_utils.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();
Future<void> handleVehicles(VehicleRepository repo) async {
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
        print('Creating vehicle');
        await _createVehicle(repo);
        break;
      case '2':
        print('Showing all vehicles');
        await _showAllVehicle(repo);
        break;
      case '3':
        print('Updating vehicle');
        await _updateVehicle(repo);
        break;
      case '4':
        print('Deleting vehicle');
        await _deleteVehicle(repo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

Future<void> _createVehicle(VehicleRepository repo) async{
  stdout.write('\nEnter RegNr: ');
  var regNr = stdin.readLineSync();
  stdout.write('Enter owner name: ');
  var ownerName = stdin.readLineSync();
  stdout.write('Enter owner ID: ');
  var ownerIdInput = stdin.readLineSync();
  int? ownerId = int.tryParse(ownerIdInput!);

  if (isValid(regNr) && isValid(ownerName) && isValid(ownerId)) {
    var vehicle = Vehicle(uuid.v4(), regNr!, Person(uuid.v4(),ownerName!, ownerId!));
    Vehicle returned = await repo.addVehicle(vehicle);
    print('\nVehicle created: ${returned.registrationNumber}');
    print(
        'Owner name: ${returned.owner.name} Owner ID: ${returned.owner.personId}');
  } else {
    print('\nInvalid input, try again.');
  }
}

Future<void> _showAllVehicle(VehicleRepository repo) async{
  var vehicles = await repo.getAll();
  if (isValid(vehicles)) {
    print('\nList of vehicles:');
    for (var vehicle in vehicles) {
      print('\nRegNr: ${vehicle.registrationNumber}');
      print(
          'Owner name: ${vehicle.owner.name} Owner ID: ${vehicle.owner.personId}');
    }
  } else {
    print('\nNo vehicles found!');
  }
}

Future<void> _updateVehicle(VehicleRepository repo) async{
  stdout.write('\nInput vehicle RegNr to update: ');
  var regNr = stdin.readLineSync();
  var vehicle = await repo.getById(regNr ?? '');

  if (isValid(vehicle)) {
    stdout.write('New RegNr (current RegNr: ${vehicle!.registrationNumber}):');
    var newRegNr = stdin.readLineSync();
    stdout.write('New Owner Name (current name: ${vehicle.owner.name}):');
    var newName = stdin.readLineSync();
    stdout.write('New Owner ID (current ID: ${vehicle.owner.personId}):');
    var newIdInput = stdin.readLineSync();
    int? newId = int.tryParse(newIdInput!);

    if (isValid(newRegNr) && isValid(newName) && isValid(newId)) {
      vehicle.registrationNumber = newRegNr!;
      vehicle.owner.name = newName!;
      vehicle.owner.personId = newId!;
      Vehicle returned = await repo.update(vehicle);
      print('\nVehicle updated: ${returned.registrationNumber}');
      print('Owner name updated: ${returned.owner.name}');
      print('Owner ID updated: ${returned.owner.personId}');
    } else {
      print('\nRegNr not valid.');
    }
  } else {
    print('\nVehicle with RegNr $regNr not found.');
  }
}

Future<void> _deleteVehicle(VehicleRepository repo) async {
  stdout.write('\nInput RegNr for vehicle to delete: ');
  var regNr = stdin.readLineSync();
  var vehicle = await repo.getById(regNr ?? '');

  if (isValid(vehicle)) {
    repo.delete(regNr ?? '');
    print('\nVehicle with RegNr ${vehicle!.registrationNumber} deleted!');
  } else {
    print('\nVehicle with RegNr $regNr not found');
  }
}
