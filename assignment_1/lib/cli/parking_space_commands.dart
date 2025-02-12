import 'dart:io';
import 'package:assignment_1/models/parking_space.dart';
import 'package:assignment_1/repositories/parking_space_repository.dart';
import 'cli_utils.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

void handleParkingSpace(ParkingSpaceRepository repo) {
  while (true) {
    print('\nParking space handling. How can I help you?');
    print('1. Create parking space.');
    print('2. Show all parking space.');
    print('3. Update parking space.');
    print('4. Delete parking space.');
    print('5. Back to Main menu.');
    stdout.write('Choose alternative (1-5): ');

    var choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        _createParkingSpace(repo);
        break;
      case '2':
        _showAllParkingSpaces(repo);
        break;
      case '3':
        _updateParkingSpace(repo);
        break;
      case '4':
        _deleteParkingSpace(repo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

void _createParkingSpace(ParkingSpaceRepository repo) {
  stdout.write('\nEnter parking space ID: ');
  var parkingSpaceId = stdin.readLineSync();
  stdout.write('Enter adress: ');
  var parkingSpaceAdress = stdin.readLineSync();
  stdout.write('Enter price per hour: ');
  var pricePerHourInput = stdin.readLineSync();

  if (parkingSpaceId != null &&
      parkingSpaceAdress != null &&
      pricePerHourInput != null) {
    var pricePerHour = int.tryParse(pricePerHourInput);
    if (pricePerHour != null) {
      var parkingSpace =
          Parkingspace(uuid.v4(),parkingSpaceId, parkingSpaceAdress, pricePerHour);

      repo.addParkingSpace(parkingSpace);
      print('\nParking space created ID: ${parkingSpace.spaceId}');
      print('Parking space adress: ${parkingSpace.adress}');
      print('Price per hour: ${parkingSpace.pricePerHour}');
    } else {
      print('\nPrice per hour has to be a number, try again.');
    }
  } else {
    print('\nInvalid input, try again.');
  }
}

void _showAllParkingSpaces(ParkingSpaceRepository repo) {
  var parkingSpaces = repo.getAll();
  if (parkingSpaces.isEmpty) {
    print('\nNo parking spaces found!');
  } else {
    print('\nList of parking spaces:');
    for (var parkingSpace in parkingSpaces) {
      print('\nParking space ID: ${parkingSpace.spaceId}');
      print('Parking space Adress: ${parkingSpace.adress}');
      print('Price per hour: ${parkingSpace.pricePerHour}');
    }
  }
}

void _updateParkingSpace(ParkingSpaceRepository repo) {
  stdout.write('\nInput parking space ID to update: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = repo.getById(parkingSpaceId ?? '');

  if (parkingSpace != null) {
    stdout.write('New parking space ID (current ID: ${parkingSpace.spaceId}):');
    var newParkingSpaceId = stdin.readLineSync();
    stdout.write('New adress (current adress: ${parkingSpace.adress}):');
    var newAdress = stdin.readLineSync();
    stdout.write(
        'New price per hour (current price per hour: ${parkingSpace.pricePerHour}):');
    var newPricePerHourInput = stdin.readLineSync();

    if (isValid(newParkingSpaceId) &&
        isValid(newAdress) &&
        isValid(newPricePerHourInput)) {
      var newPricePerHour = int.tryParse(newPricePerHourInput!);

      parkingSpace.spaceId = newParkingSpaceId!;
      parkingSpace.adress = newAdress!;
      parkingSpace.pricePerHour = newPricePerHour!;
      repo.update(parkingSpace);
      print('\nParking space ID updated: ${parkingSpace.spaceId}');
      print('Parking space Adress updated: ${parkingSpace.adress}');
      print('Owner ID updated: ${parkingSpace.pricePerHour}');
    } else {
      print('\nRegNr not valid.');
    }
  } else {
    print('\nVehicle with RegNr $parkingSpaceId not found.');
  }
}

void _deleteParkingSpace(ParkingSpaceRepository repo) {
  stdout.write('\nInput ID for parking space to delete: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = repo.getById(parkingSpaceId ?? '');

  if (parkingSpace != null) {
    repo.delete(parkingSpaceId ?? '');
    print('\nParking space with ID: ${parkingSpace.spaceId} deleted');
  } else {
    print('\nParking space with ID: $parkingSpaceId not found');
  }
}
