import 'dart:convert';

import 'package:server/repositories/parking_space_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

ParkingSpaceRepository parkingSpaceRepo = ParkingSpaceRepository();

Future<Response> createParkingSpaceHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  Parkingspace parkingSpace = Parkingspace.fromJson(json);
  print(
      'Parking space created: ${parkingSpace.spaceId}, ${parkingSpace.adress}');

  Parkingspace? createdParkingSpace = await parkingSpaceRepo.add(parkingSpace);

  return Response.ok(jsonEncode(createdParkingSpace.toJson()));
}

Future<Response> getParkingSpacesHandler(Request request) async {
  List<Parkingspace> parkingSpaces = await parkingSpaceRepo.getAll();
  List<dynamic> parkingSpaceList =
      parkingSpaces.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(parkingSpaceList));
}

Future<Response> getParkingSpaceByIdHandler(Request request) async {
  String? spaceId = request.params['spaceId'];
  if (spaceId != null) {
    try {
      Parkingspace? foundParkingSpace = await parkingSpaceRepo.getById(spaceId);
      print('Parking space found: $foundParkingSpace');
      return Response.ok(jsonEncode(foundParkingSpace.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body:
              'An error occurred while trying to get the parking space: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Parking space not found');
  }
}

Future<Response> updateParkingSpaceHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Parkingspace parkingSpace = Parkingspace.fromJson(json);
    Parkingspace updatedParkingSpace =
        await parkingSpaceRepo.update(parkingSpace.id, parkingSpace);
    return Response.ok(jsonEncode(updatedParkingSpace.toJson()));
  }
  return Response.notFound('Parking space not found');
}

Future<Response> deleteParkingSpaceHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    try {
      Parkingspace removedParkingSpace = await parkingSpaceRepo.delete(idStr);
      return Response.ok(jsonEncode(removedParkingSpace.toJson()));
    } catch (e) {
      if (e.toString() == 'Exception: Parking space with id: $idStr not found') {
        return Response.notFound('Parking space with ID "$idStr" found');
      }
      return Response.internalServerError(
          body:
              'An error occurred while trying to delete the parking space: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Invalid request: ID must be provided.');
  }
}
