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
  print('Parking created: ${parking.id}, vehicle registration number: ${parking.vehicle.registrationNumber}, parking space id: ${parking.parkingSpace.id}');

  Parking? createdParking = await parkingRepo.addParking(parking);

  return Response.ok(jsonEncode(createdParking.toJson()));
}

Future<Response> getParkingsHandler(Request request) async {
  List<Parking> parkings = await parkingRepo.getAll();
  List<dynamic> parkingList = parkings.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(parkingList));
}

Future<Response> getParkingByIdHandler(Request request) async {
  String? parkingId = request.params['id'];
  if (parkingId != null) {
      Parking? foundParking = await parkingRepo.getById(parkingId);
      print('Parking found: $foundParking');
      return Response.ok(jsonEncode(foundParking?.toJson()));
    } else {
      return Response.notFound('Parking not found');
  }
}

Future<Response> updateParkingHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Parking parking = Parking.fromJson(json);
    Parking updatedParking = await parkingRepo.update(parking);
    return Response.ok(jsonEncode(updatedParking.toJson()));
  }
  return Response.notFound('Parking not found');
}

Future<Response> deleteParkingHandler(Request request) async {
  String? parkingId = request.params['id'];
  if (parkingId != null) {
      Parking removedParking = await parkingRepo.delete(parkingId);
      return Response.ok(jsonEncode(removedParking.toJson()));
    } else {
      return Response.notFound('Parking not found');
    }
}