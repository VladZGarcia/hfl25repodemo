import 'package:assignment_1/models/parking_space.dart';

class ParkingSpaceRepository {
  List<Parkingspace> parkingSpaces = [];

  void addParkingSpace(Parkingspace parkingspace) =>
      parkingSpaces.add(parkingspace);
  List<Parkingspace> getAll() => parkingSpaces;
  Parkingspace? getById(String id) => parkingSpaces
      .cast<Parkingspace?>()
      .firstWhere((p) => p?.spaceId == id, orElse: () => null);
  void update(Parkingspace parkingspace) {
    var index =
        parkingSpaces.indexWhere((p) => p.spaceId == parkingspace.spaceId);
    if (index != -1) parkingSpaces[index] = parkingspace;
  }

  void delete(String id) => parkingSpaces.removeWhere((p) => p.spaceId == id);
}
