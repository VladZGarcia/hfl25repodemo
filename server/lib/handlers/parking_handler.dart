import 'dart:convert';

import 'package:server/repositories/parking_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

ParkingRepository parkingRepo = ParkingRepository();

Future<Response> createParkingHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  Parking parking = Parking.fromJson(json);
  print(
      'Parking created: ${parking.id}, vehicle registration number: ${parking.vehicle.registrationNumber}, parking space id: ${parking.parkingSpace.id}');

  Parking? createdParking = await parkingRepo.add(parking);

  return Response.ok(jsonEncode(createdParking.toJson()));
}

Future<Response> getParkingsHandler(Request request) async {
  List<Parking> parkings = await parkingRepo.getAll();
  List<dynamic> parkingList = parkings.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(parkingList));
}

Future<Response> getParkingByIdHandler(Request request) async {
  String? parkingId = request.params['registrationNumber'];
  if (parkingId != null) {
    try {
      Parking? foundParking = await parkingRepo.getById(parkingId);
      print('Parking found: $foundParking');
      return Response.ok(jsonEncode(foundParking.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body:
              'An error occurred while trying to get the parking: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Parking not found');
  }
}

Future<Response> updateParkingHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Parking parking = Parking.fromJson(json);
    Parking updatedParking = await parkingRepo.update(parking.id, parking);
    return Response.ok(jsonEncode(updatedParking.toJson()));
  }
  return Response.notFound('Parking not found');
}

Future<Response> deleteParkingHandler(Request request) async {
  String? parkingId = request.params['id'];
  if (parkingId != null) {
    try {
      Parking removedParking = await parkingRepo.delete(parkingId);
    return Response.ok(jsonEncode(removedParking.toJson()));
    } catch (e) {
      if (e.toString() == 'Exception: Parking with id: $parkingId not found') {
        return Response.notFound('Parking with id "$parkingId" found');
      }
      return Response.internalServerError(
          body: 'An error occurred while trying to delete the parking: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Invalid request: ID must be provided.');
  }
}
