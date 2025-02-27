import 'dart:io';
import 'package:assignment_1/repositories/parking_space_repository.dart';
import 'package:shared/shared.dart';
import 'cli_utils.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> handleParkingSpace(ParkingSpaceRepository repo) async {
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
        print('Creating parking space');
        await _createParkingSpace(repo);
        break;
      case '2':
        print('Showing all parking spaces');
        await _showAllParkingSpaces(repo);
        break;
      case '3':
        print('Updating parking space');
        await _updateParkingSpace(repo);
        break;
      case '4':
        print('Deleting parking space');
        await _deleteParkingSpace(repo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

Future<void> _createParkingSpace(ParkingSpaceRepository repo) async {
  stdout.write('\nEnter parking space ID: ');
  var parkingSpaceId = stdin.readLineSync();
  stdout.write('Enter adress: ');
  var parkingSpaceAdress = stdin.readLineSync();
  stdout.write('Enter price per hour: ');
  var pricePerHourInput = stdin.readLineSync();

  if (isValid(parkingSpaceId) &&
      isValid(parkingSpaceAdress) &&
      isValid(pricePerHourInput)) {
    var pricePerHour = int.tryParse(pricePerHourInput!);
    if (pricePerHour != null) {
      var parkingSpace =
          Parkingspace(uuid.v4(),parkingSpaceId!, parkingSpaceAdress!, pricePerHour);

      Parkingspace returned = await repo.addParkingSpace(parkingSpace);
      print('\nParking space created ID: ${returned.spaceId}');
      print('Parking space adress: ${returned.adress}');
      print('Price per hour: ${returned.pricePerHour}');
    } else {
      print('\nPrice per hour has to be a number, try again.');
    }
  } else {
    print('\nInvalid input, try again.');
  }
}

Future<void> _showAllParkingSpaces(ParkingSpaceRepository repo) async{
  var parkingSpaces = await repo.getAll();
  if (isValid(parkingSpaces)) {
    print('\nList of parking spaces:');
    for (var parkingSpace in parkingSpaces) {
      print('\nParking space ID: ${parkingSpace.spaceId}');
      print('Parking space Adress: ${parkingSpace.adress}');
      print('Price per hour: ${parkingSpace.pricePerHour}');
    }
  } else {
    print('\nNo parking spaces found!');
  }
}

Future<void> _updateParkingSpace(ParkingSpaceRepository repo) async {
  stdout.write('\nInput parking space ID to update: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = await repo.getById(parkingSpaceId ?? '');

  if (isValid(parkingSpace)) {
    stdout.write('New parking space ID (current ID: ${parkingSpace!.spaceId}):');
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
      Parkingspace returned = await repo.update(parkingSpace);
      print('\nParking space ID updated: ${returned.spaceId}');
      print('Parking space Adress updated: ${returned.adress}');
      print('Price per hour updated: ${returned.pricePerHour}');
    } else {
      print('\nSpace id not valid.');
    }
  } else {
    print('\nVehicle with space id $parkingSpaceId not found.');
  }
}

Future<void> _deleteParkingSpace(ParkingSpaceRepository repo) async {
  stdout.write('\nInput ID for parking space to delete: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = await repo.getById(parkingSpaceId ?? '');

  if (isValid(parkingSpace)) {
    repo.delete(parkingSpaceId ?? '');
    print('\nParking space with ID: ${parkingSpace!.spaceId} deleted');
  } else {
    print('\nParking space with ID: $parkingSpaceId not found');
  }
}
