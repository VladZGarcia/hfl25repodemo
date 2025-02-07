import 'package:assignment_1/models/parking_space.dart';

class ParkingSpaceRepository {
  List<Parkingspace> parkingSpace = [];

  void addParkingSpace(Parkingspace parkingspace) => parkingSpace.add(parkingspace);
  List<Parkingspace> getAll() => parkingSpace;
  Parkingspace? getById(String id) => parkingSpace.firstWhere((p) => p.id == id,
      orElse: () => throw Exception('Parking space not found'));
  void update(Parkingspace parkingspace) {
    var index = parkingSpace.indexWhere((p) => p.id == parkingspace.id);
    if (index != -1) parkingSpace[index] = parkingspace;
  }
  void delete(String id) => parkingSpace.removeWhere((p) => p.id == id);
}