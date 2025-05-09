import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class VehicleRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  List<Vehicle> vehicles = [];

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final url = Uri.parse('$baseUrl/vehicles');

    Response response = await http.post(
      url,
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body);
    return Vehicle.fromJson(json);
  }

  Future<List<Vehicle>> getAll() async {
    final url = Uri.parse('$baseUrl/vehicles');
    Response response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body); // decoded json list
    final List<Vehicle> vehicles =
        (json as List<dynamic>).map((e) => Vehicle.fromJson(e)).toList();

    return vehicles;
  }

  Future<Vehicle?> getById(String regNr) async {
    final url = Uri.parse('$baseUrl/vehicles/$regNr');
    Response response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      if (response.body.trim() == 'null') {
        return null;
      }
      final json = jsonDecode(response.body); // decoded json
      return Vehicle.fromJson(json);
    } else {
      return null;
    }
  }

  Future<Vehicle> update(Vehicle vehicle) async {
    final url = Uri.parse('$baseUrl/vehicles/${vehicle.id}');
    Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Vehicle.fromJson(json);
  }

  Future<Vehicle?> delete(String id) async {
    final url = Uri.parse('$baseUrl/vehicles/$id');
    Response response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      if (response.body.trim() == 'null') {
        return null;
      }
    }
    final json = await jsonDecode(response.body); // decoded json
    return Vehicle.fromJson(json);
  }
}
