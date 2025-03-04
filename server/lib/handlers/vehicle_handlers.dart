import 'dart:convert';

import 'package:server/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

VehicleRepository vehicleRepo = VehicleRepository();

Future<Response> createVehicleHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  Vehicle vehicle = Vehicle.fromJson(json);
  print('Vehicle created: ${vehicle.registrationNumber}, owner name: ${vehicle.owner.name}');

  Vehicle? createdVehicle = await vehicleRepo.add(vehicle);

  return Response.ok(jsonEncode(createdVehicle.toJson()));
}

Future<Response> getVehiclesHandler(Request request) async {
  List<Vehicle> vehicles = await vehicleRepo.getAll();
  List<dynamic> vehicleList = vehicles.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(vehicleList));
}

Future<Response> getVehicleByIdHandler(Request request) async {
  String? vehicleRegNr = request.params['registrationNumber'];
  if (vehicleRegNr != null) {
      Vehicle? foundVehicle = await vehicleRepo.getById(vehicleRegNr);
      print('Vehicle found: $foundVehicle');
      return Response.ok(jsonEncode(foundVehicle?.toJson()));
    } else {
      return Response.notFound('Vehicle not found');
  }
}

Future<Response> updateVehicleHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    var vehicle = Vehicle.fromJson(json);
    var updatedVehicle = await vehicleRepo.update(vehicle.id, vehicle);
    return Response.ok(jsonEncode(updatedVehicle.toJson()));
  }
  return Response.notFound('Vehicle not found');
}

Future<Response> deleteVehicleHandler(Request request) async {
  String? vehicleRegNr = request.params['registrationNumber'];
  if (vehicleRegNr != null) {
      Vehicle removedVehicle = await vehicleRepo.delete(vehicleRegNr);
      return Response.ok(jsonEncode(removedVehicle.toJson()));
    } else {
      return Response.notFound('Vehicle not found');
    }
}