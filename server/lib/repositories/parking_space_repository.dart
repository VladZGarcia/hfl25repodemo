import 'package:shared/shared.dart';

class ParkingSpaceRepository {
  List<Parkingspace> parkingSpaces = [];

  Future<Parkingspace> addParkingSpace(Parkingspace parkingspace) async {
    parkingSpaces.add(parkingspace);
    return parkingspace;
  }

  Future<List<Parkingspace>> getAll() async => parkingSpaces;

  Future<Parkingspace?> getById(String spaceId) async => parkingSpaces
      .cast<Parkingspace?>()
      .firstWhere((p) => p?.spaceId == spaceId, orElse: () => null);

  Future<Parkingspace> update(Parkingspace parkingspace) async {
    var index =
        parkingSpaces.indexWhere((p) => p.spaceId == parkingspace.spaceId);
    if (index != -1) parkingSpaces[index] = parkingspace;
    return parkingspace;
  }

  Future<Parkingspace> delete(String id) async {
    Parkingspace removedParkingspace =
        parkingSpaces.cast<Parkingspace>().firstWhere((p) => p.spaceId == id);
    parkingSpaces.removeWhere((p) => p.spaceId == id);
    return removedParkingspace;
  }
}
