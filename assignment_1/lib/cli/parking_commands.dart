import 'dart:io';
import 'package:assignment_1/repositories/parking_repository.dart';
import 'package:assignment_1/repositories/parking_space_repository.dart';
import 'package:assignment_1/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'cli_utils.dart';

final uuid = Uuid();

Future<void> handleParking(
    ParkingRepository repo,
    ParkingSpaceRepository parkingSpaceRepo,
    VehicleRepository vehicleRepo) async {
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
        print('Creating parking');
        await _createParking(repo, parkingSpaceRepo, vehicleRepo);
        break;
      case '2':
        print('Showing all parking');
        await _showAllParkings(repo);
        break;
      case '3':
        print('Updating parking');
        await _updateParking(repo, vehicleRepo);
        break;
      case '4':
        print('Deleting parking');
        await _deleteParking(repo, vehicleRepo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

Future<void> _createParking(
    ParkingRepository repo,
    ParkingSpaceRepository parkingSpaceRepo,
    VehicleRepository vehicleRepo) async {
  var parkingSpaces = await parkingSpaceRepo.getAll();
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
    return;
  }
  stdout.write('Choose a parking space ID to start parking: ');
  var parkingSpaceId = stdin.readLineSync();
  var parkingSpace = await parkingSpaceRepo.getById(parkingSpaceId ?? '');
  print('Avaible vehicles:');
  var vehicles = await vehicleRepo.getAll();
  if (isValid(vehicles)) {
    for (var vehicle in vehicles) {
      print('\nVehicle regnr: ${vehicle.registrationNumber}');
    }
  } else {
    print('\nNo vehicles found! You need to create a vehicle first.');
    return;
  }
  stdout.write('Choose a vehicle regnr to start parking: ');
  var vehicleRegnr = stdin.readLineSync();
  var vehicle = vehicles.cast<Vehicle?>()
      .firstWhere((vehicle) => vehicle?.registrationNumber == vehicleRegnr, orElse: () => null);

  /* var vehicleId = vehicleExist.id;
  var vehicle = await vehicleRepo.getById(vehicleId); */

  if (isValid(parkingSpace) && isValid(vehicle)) {
    DateTime startTime = DateTime.now();
    //String formattedStartTime = formatDateTime(startTime);
    String formattedStartTime = parkingSpace!.formatTime(startTime);
    stdout.write(
        'Enter parking time in hours or just enter for ongoing parking: ');
    var parkingHourInput = stdin.readLineSync();
    var parkingHour = int.tryParse(parkingHourInput ?? '');

    if (isValid(parkingHour)) {
      DateTime endTime =
          startTime.add(Duration(hours: int.parse(parkingHourInput!)));
      String formattedEndTime = parkingSpace.formatTime(endTime);
      print('\nParking started at: $formattedStartTime.');
      print('Ending at $formattedEndTime.');
      print('Vehicle regnr: $vehicleRegnr.');
      print('Price per hour: ${parkingSpace.pricePerHour}kr/h');
      double price = calculatePrice(
          startTime, endTime, parkingSpace.pricePerHour.toDouble());
      print(
          'Expected price: $price kr. \nRemember to end parking when vehicle leaves.');
      var newParking =
          Parking(uuid.v4(), vehicle!, parkingSpace, startTime, endTime);
      await repo.addParking(newParking);
    } else {
      Null endTime;
      print('\nParking started at $formattedStartTime.');
      print('Vehicle regnr: $vehicleRegnr.');
      print('Price per hour: ${parkingSpace.pricePerHour}kr/h.');
      print('\nRemember to end parking when vehicle leaves.');
      var newParking =
          Parking(uuid.v4(), vehicle!, parkingSpace, startTime, endTime);
      await repo.addParking(newParking);
    }
  } else {
    print('\nInvalid input, try again.');
  }
}

Future<void> _showAllParkings(ParkingRepository repo) async {
  var parkings = await repo.getAll();
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

Future<void> _updateParking(
    ParkingRepository repo, VehicleRepository vehicleRepo) async {
  stdout.write('\nInput RegNr for car in parking to update: ');
  var parkingCarRegNr = stdin.readLineSync();
  var vehicles = await vehicleRepo.getAll();
  var vehicle = vehicles
      .firstWhere((vehicle) => vehicle.registrationNumber == parkingCarRegNr);
  var parking = await repo.getById(vehicle.id);

  if (isValid(parking)) {
    stdout.write('New end time (current end time: ${parking?.endTime}):');
    var newEndTime = stdin.readLineSync();
    if (isValid(newEndTime)) {
      parking?.endTime = DateTime.parse(newEndTime!);
      await repo.update(parking!);
      print(
          '\nParking with car RegNr:${parking.vehicle.registrationNumber} updated');
    } else {
      print('\nInvalid input, try again.');
    }
  } else {
    print('\nParking with car RegNr:$parkingCarRegNr not found');
  }
}

Future<void> _deleteParking(
    ParkingRepository repo, VehicleRepository vehicleRepo) async {
  stdout.write('\nInput RegNr for car in parking to delete: ');
  var parkingCarRegNr = stdin.readLineSync();
  var vehicles = await vehicleRepo.getAll();
  var vehicle = vehicles.cast<Vehicle?>()
      .firstWhere((vehicle) => vehicle?.registrationNumber == parkingCarRegNr, orElse:() => null);
  if (isValid(vehicle)) {
    var parking = await repo.getById(vehicle!.id);

    if (isValid(parking)) {
      await repo.delete(parking?.id ?? '');
      print(
          '\nParking with ID:${parking?.id} and car RegNr: ${parking?.vehicle.registrationNumber} deleted');
    } else {
      print('\nParking with car RegNr: $parkingCarRegNr not found');
    }
  } else {
    print('\nParking with car RegNr: $parkingCarRegNr not found');
  }
}
