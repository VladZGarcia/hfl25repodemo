import 'package:shared/cli_shared.dart';

class ParkingSpaceRepository {
  List<Parkingspace> parkingSpaces = [];

  Future<void> addParkingSpace(Parkingspace parkingspace) async =>
      parkingSpaces.add(parkingspace);
  Future<List<Parkingspace>> getAll() async => parkingSpaces;
  Future<Parkingspace?> getById(String id) async => parkingSpaces
      .cast<Parkingspace?>()
      .firstWhere((p) => p?.spaceId == id, orElse: () => null);
  Future<void> update(Parkingspace parkingspace) async {
    var index =
        parkingSpaces.indexWhere((p) => p.spaceId == parkingspace.spaceId);
    if (index != -1) parkingSpaces[index] = parkingspace;
  }

  Future<void> delete(String id) async => parkingSpaces.removeWhere((p) => p.spaceId == id);
}
