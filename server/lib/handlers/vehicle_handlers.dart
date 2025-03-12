import 'dart:convert';

import 'package:server/models/vehicle_entity.dart';
import 'package:server/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

VehicleRepository vehicleRepo = VehicleRepository();

Future<Response> createVehicleHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  var vehicle = Vehicle.fromJson(json);
  print(
      'Vehicle created: ${vehicle.registrationNumber}, owner name: ${vehicle.owner.name}');

  var vehicleEntity = await vehicleRepo.add(vehicle.toEntity());
  Vehicle? createdVehicle = await vehicleEntity.toModel();

  return Response.ok(jsonEncode(createdVehicle.toJson()));
}

Future<Response> getVehiclesHandler(Request request) async {
  final vehicleEntities = await vehicleRepo.getAll();
  List<Vehicle> vehicleList = await Future.wait(vehicleEntities.map((e) => e.toModel()));
  final payload = vehicleList.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(payload),
      headers: {'content-type': 'application/json'}
      );
}

Future<Response> getVehicleByIdHandler(Request request) async {
  String? vehicleRegNr = request.params['registrationNumber'];
  if (vehicleRegNr != null) {
    try {
      var vehicleEntity = await vehicleRepo.getById(vehicleRegNr);
      var vehicle = await vehicleEntity.toModel();
    print('Vehicle found: $vehicle');
    return Response.ok(jsonEncode(vehicle.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body: 'An error occurred while trying to get the vehicle: ${e.toString()}');
  }
  } else {
    return Response.badRequest(body: 'Vehicle not found');
  }
}

Future<Response> updateVehicleHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var vehicle = Vehicle.fromJson(json);

    var vehicleEntity = vehicle.toEntity();
    var updatedVehicleEntity = await vehicleRepo.update(vehicle.id, vehicleEntity);
    var updatedVehicle = await updatedVehicleEntity.toModel();

    return Response.ok(jsonEncode(updatedVehicle.toJson()));
  }
  return Response.notFound('Vehicle not found');
}

Future<Response> deleteVehicleHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    try {
      var removedVehicleEntity = await vehicleRepo.delete(idStr);
      var removedVehicle = await removedVehicleEntity.toModel();
      
      return Response.ok(jsonEncode(removedVehicle.toJson()));
    } catch (e) {
      if (e.toString() == 'Exception: Vehicle with id: $idStr not found') {
        return Response.notFound('Vehicle with ID "$idStr" not found');
      }
      return Response.internalServerError(
          body:
              'An error occurred while tryin to delete vehicle: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Invalid request: ID must be provided.');
  }
}
