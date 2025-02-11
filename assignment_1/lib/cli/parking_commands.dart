import 'dart:io';
import 'package:assignment_1/repositories/parking_repository.dart';
import 'package:assignment_1/repositories/parking_space_repository.dart';
import 'package:assignment_1/repositories/vehicle_repository.dart';

void handleParking(ParkingRepository repo, ParkingSpaceRepository parkingSpaceRepo, VehicleRepository vehicleRepo) {
  while (true) {
    print('\nParking handling. How can I help you?');
    print('1. Create parking.');
    print('2. Show all parking.');
    print('3. Update parking.');
    print('4. Delete parking.');
    print('5. Back to Main menu.');
    stdout.write('Choose alternative (1-5): ');

    var choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        _createParking(repo, parkingSpaceRepo, vehicleRepo);
        break;
      case '2':
        _showAllParkings(repo);
        break;
      case '3':
        _updateParking(repo);
        break;
      case '4':
        _deleteParking(repo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

void _createParking(ParkingRepository repo, ParkingSpaceRepository parkingSpaceRepo, VehicleRepository vehicleRepo) {
  var parkingSpaces = parkingSpaceRepo.getAll();
  if (parkingSpaces.isEmpty) {
    print('\nNo parking spaces found! You need to create a parking space first.');
  } else {
    print('\nList of parking spaces:');
    for (var parkingSpace in parkingSpaces) {
      print('\nParking space ID: ${parkingSpace.id}');
      print('Parking space Adress: ${parkingSpace.adress}');
      print('Price per hour: ${parkingSpace.pricePerHour}');
    }
  }
}

void _showAllParkings(ParkingRepository repo) {
  var parkings= repo.getAll();
  if (parkings.isEmpty) {
    print('\nNo started parking found!');
  } else {
    print('\nList of started parking:');
    for (var parking in parkings) {
      print('\nParking ID: ${parking.id}');
      print('\nParking space ID: ${parking.parkingSpace.id}');
      print('Vehicle regnr: ${parking.vehicle.registrationNumber}');
      print('Owner name: ${parking.vehicle.owner.name}');
      print('Price per hour: ${parking.parkingSpace.pricePerHour}');
    }
  }
}

void _updateParking(ParkingRepository repo) {
}

void _deleteParking(ParkingRepository repo) {
  stdout.write('\nInput ID for parking to delete: ');
  var parkingId = stdin.readLineSync();
  var parking = repo.getById(parkingId ?? '');

  if (parking != null) {
    repo.delete(parkingId ?? '');
    print('\nParking with ID:${parking.id} deleted');
  } else {
    print('\nParking with ID:$parkingId not found');
  }
}