import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'dart:io' show Platform;

class VehicleRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  User? get credential => FirebaseAuth.instance.currentUser;

  List<Vehicle> vehicles = [];

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    /* final url = Uri.parse('$baseUrl/vehicles');

    Response response = await http.post(
      url,
      body: jsonEncode(vehicle.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body);
    return Vehicle.fromJson(json); */

    // add vehicle to Firestore under the logged-in user
    
      await FirebaseFirestore.instance
          .collection('persons')
          .doc(credential?.uid)
          .collection('vehicles')
          .doc(vehicle.id)
          .set(vehicle.toJson());

    return vehicle;
  }

  Future<List<Vehicle>> getAll() async {
    /* final url = Uri.parse('$baseUrl/vehicles');
    Response response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body); // decoded json list
    final List<Vehicle> vehicles =
        (json as List<dynamic>).map((e) => Vehicle.fromJson(e)).toList(); */
    // get all vehicles for the logged-in user from Firestore
    if (credential == null) {
      throw Exception("User not logged in");
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('vehicles')
        .get();
    final List<Vehicle> vehicles = snapshot.docs
        .map((doc) => Vehicle.fromJson(doc.data()))
        .toList();

    return vehicles;
  }

  Future<Vehicle?> getById(String id) async {
    /* final url = Uri.parse('$baseUrl/vehicles/$regNr');
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
    } */
    // get vehicle with regNr from a person from Firestore
    final document =
        await FirebaseFirestore.instance
            .collection('persons')
            .doc(credential?.uid)
            .collection('vehicles')
            .doc(id)
            .get();

    if (document.exists) {
      final json = document.data();
      if (json != null) {
        return Vehicle.fromJson(json);
      }
    } else {
      throw Exception('Vehicle not found');
    }
    return null;
  }

  Future<Vehicle> update(Vehicle vehicle) async {
    /* final url = Uri.parse('$baseUrl/vehicles/${vehicle.id}');
    Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vehicle.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Vehicle.fromJson(json); */
    // update vehicle in Firestore
    
      await FirebaseFirestore.instance
          .collection('persons')
          .doc(credential?.uid)
          .collection('vehicles')
          .doc(vehicle.id)
          .update(vehicle.toJson());
    
    return vehicle;
  }

  Future<Vehicle?> delete(String id) async {
    /* final url = Uri.parse('$baseUrl/vehicles/$id');
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
    return Vehicle.fromJson(json); */
    // delete vehicle from Firestore
    
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('vehicles')
        .doc(id)
        .delete();
    return null; // No return value needed, just delete
  }
}
