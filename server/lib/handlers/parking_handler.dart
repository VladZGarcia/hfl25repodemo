import 'dart:convert';

import 'package:server/models/parking_entity.dart';
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

  var parkingEntity = await parkingRepo.add(parking.toEntity());
  Parking? createdParking = await parkingEntity.toModel();

  return Response.ok(jsonEncode(createdParking.toJson()));
}

Future<Response> getParkingsHandler(Request request) async {
  final parkingEntities = await parkingRepo.getAll();
  List<dynamic> parkingList = await Future.wait(parkingEntities.map((e) => e.toModel()));
  final payload = parkingList.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(payload),
      headers: {'content-type': 'application/json'}
      );
}

Future<Response> getParkingByIdHandler(Request request) async {
  String? parkingId = request.params['vehicleId'];
  if (parkingId != null) {
    try {
      var parkingEntity = await parkingRepo.getById(parkingId);
      var parking = await parkingEntity.toModel();
      print('Parking found: $parking');
      return Response.ok(jsonEncode(parking.toJson()));
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
    var parking = Parking.fromJson(json);

    var parkingEntity = parking.toEntity();
    var updatedParkingEntity = await parkingRepo.update(parking.id, parkingEntity);
    var updatedParking = await updatedParkingEntity.toModel();

    return Response.ok(jsonEncode(updatedParking.toJson()));
  }
  return Response.notFound('Parking not found');
}

Future<Response> deleteParkingHandler(Request request) async {
  String? parkingId = request.params['id'];
  if (parkingId != null) {
    try {
      var removedParkingEntity = await parkingRepo.delete(parkingId);
      var removedParking = await removedParkingEntity.toModel();
      
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
