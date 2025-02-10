import 'dart:io';
import 'package:assignment_1/repositories/parking_repository.dart';

void handleParking(ParkingRepository repo) {
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
        _createParking(repo);
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

void _createParking(ParkingRepository repo) {
}

void _showAllParkings(ParkingRepository repo) {
}

void _updateParking(ParkingRepository repo) {
}

void _deleteParking(ParkingRepository repo) {
}