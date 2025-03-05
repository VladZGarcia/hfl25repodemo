import 'package:server/repositories/file_repository.dart';
import 'package:shared/shared.dart';

class ParkingSpaceRepository extends FileRepository<Parkingspace> {
  ParkingSpaceRepository() : super('parkingspaces.json');

  @override
  Parkingspace fromJson(Map<String, dynamic> json) {
    return Parkingspace.fromJson(json);
  }

  @override
  String idFromType(Parkingspace item) {
    return item.id;
  }

  @override
  String simpleIdFromType(Parkingspace item) {
    return item.spaceId;
  }

  @override
  Map<String, dynamic> toJson(Parkingspace item) {
    return item.toJson();
  }

  @override
  Future<Parkingspace> getById(String id) async {
    var parkingspaces = await readFile();
    try {
      return parkingspaces.firstWhere((parkingspace) => simpleIdFromType(parkingspace) == id);
    } catch (e) {
      throw Exception('Parking space with ID: "$id" not found');
    }
  }

  /* List<Parkingspace> parkingSpaces = [];

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
  } */
}
