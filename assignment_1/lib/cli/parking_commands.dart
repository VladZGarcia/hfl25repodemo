import 'dart:io';
import 'package:assignment_1/models/parking.dart';
import 'package:assignment_1/repositories/parking_repository.dart';
import 'package:assignment_1/repositories/parking_space_repository.dart';
import 'package:assignment_1/repositories/vehicle_repository.dart';
import 'package:uuid/uuid.dart';
import 'cli_utils.dart';

final uuid = Uuid();

void handleParking(ParkingRepository repo,
    ParkingSpaceRepository parkingSpaceRepo, VehicleRepository vehicleRepo) {
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

void _createParking(ParkingRepository repo,
    ParkingSpaceRepository parkingSpaceRepo, VehicleRepository vehicleRepo) {
  var parkingSpaces = parkingSpaceRepo.getAll();
  if (isValid(parkingSpaces)) {
    print('\nList of parking spaces:');
    for (var parkingSpace in parkingSpaces) {
      print('\nParking space ID: ${parkingSpace.spaceId}');
      print('Parking space Adress: ${parkingSpace.adress}');
      print('Price per hour: ${parkingSpace.pricePerHour}');
    }
  } else {
    print(
        '\nNo parking spaces found! You need to create a parking space first.');
  }
  stdout.write('Choose a parking space ID to start parking: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = parkingSpaceRepo.getById(parkingSpaceId ?? '');
  print('Avaible vehicles:');
  var vehicles = vehicleRepo.getAll();
  if (isValid(vehicles)) {
    for (var vehicle in vehicles) {
      print('\nVehicle regnr: ${vehicle.registrationNumber}');
    }
  } else {
    print('\nNo vehicles found! You need to create a vehicle first.');
  }
  stdout.write('Choose a vehicle regnr to start parking: ');
  var vehicleRegnr = stdin.readLineSync();
  var vehicle = vehicleRepo.getById(vehicleRegnr ?? '');
  if (isValid(parkingSpace) && isValid(vehicle)) {
    DateTime startTime = DateTime.now();
    String formattedStartTime = formatDateTime(startTime);
    stdout.write(
        'Enter parking time in hours or just enter for ongoing parking: ');
    var parkingHourInput = stdin.readLineSync();
    var parkingHour = int.tryParse(parkingHourInput ?? '');
    
    if (isValid(parkingHour)) {
      DateTime endTime =
          startTime.add(Duration(hours: int.parse(parkingHourInput!)));
      String formattedEndTime = formatDateTime(endTime);
      print(
          '\nParking started $formattedStartTime. Ending at $formattedEndTime. Vehicle regnr: $vehicleRegnr. Price per hour: ${parkingSpace!.pricePerHour}kr/h');
      double price = calculatePrice(
          startTime, endTime, parkingSpace.pricePerHour.toDouble());
      print(
          'Expected price: $price kr. \nRemember to end parking when vehicle leaves.');
      var newParking =
          Parking(uuid.v4(), vehicle!, parkingSpace, startTime, endTime);
      repo.addParking(newParking);
    } else {
      Null endTime;
      print(
          '\nParking started $formattedStartTime. Vehicle regnr: $vehicleRegnr. Price per hour: ${parkingSpace!.pricePerHour}kr/h. \nRemember to end parking when vehicle leaves.');
      var newParking =
          Parking(uuid.v4(), vehicle!, parkingSpace, startTime, endTime);
      repo.addParking(newParking);
    }
  } else {
    print('\nInvalid input, try again.');
  }
}

void _showAllParkings(ParkingRepository repo) {
  var parkings = repo.getAll();
  if (isValid(parkings)) {
    print('\nList of started parking:');
    for (var parking in parkings) {
      print('\nParking ID: ${parking.id}');
      print('Parking space ID: ${parking.parkingSpace.spaceId}');
      print('Vehicle regnr: ${parking.vehicle.registrationNumber}');
      print('Owner name: ${parking.vehicle.owner.name}');
      print('Price per hour: ${parking.parkingSpace.pricePerHour}');
      print('Start time: ${formatDateTime(parking.startTime)}');

      if (isValid(parking.endTime)) {
        print('End time: ${formatDateTime(parking.endTime!)}');
        double price = calculatePrice(parking.startTime, parking.endTime!,
            parking.parkingSpace.pricePerHour.toDouble());
        print(
            'Expected price: $price kr. \nRemember to end parking when vehicle leaves.');
      } else {
        print('Ongoing parking! ');
        double price = calculatePrice(parking.startTime, DateTime.now(),
            parking.parkingSpace.pricePerHour.toDouble());
            print(
            'Cost for parking  is: $price kr. \nRemember to end parking when vehicle leaves.');
      }
    }
  } else {
    print('\nNo started parking found!');
  }
}

void _updateParking(ParkingRepository repo) {
  stdout.write('\nInput ID for parking to update: ');
  var parkingId = stdin.readLineSync();
  var parking = repo.getById(parkingId ?? '');

  if (isValid(parking)) {
    stdout.write('New end time (current end time: ${parking?.endTime}):');
    var newEndTime = stdin.readLineSync();
    if (isValid(newEndTime)) {
      parking?.endTime = DateTime.parse(newEndTime!);
      repo.update(parking!);
      print('\nParking with ID:${parking.id} updated');
    } else {
      print('\nInvalid input, try again.');
    }
  } else {
    print('\nParking with ID:$parkingId not found');
  }
}

void _deleteParking(ParkingRepository repo) {
  stdout.write('\nInput ID for parking to delete: ');
  var parkingId = stdin.readLineSync();
  var parking = repo.getById(parkingId ?? '');

  if (isValid(parking)) {
    repo.delete(parkingId ?? '');
    print('\nParking with ID:${parking?.id} deleted');
  } else {
    print('\nParking with ID:$parkingId not found');
  }
}
