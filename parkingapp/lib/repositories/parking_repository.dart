import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class ParkingRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

    User? get credential => FirebaseAuth.instance.currentUser;

  List<Parking> parkings = [];

  Future<Parking> addParking(Parking parking) async {
    /* final url = Uri.parse('$baseUrl/parkings');

    Response response = await http.post(url,
        body: jsonEncode(parking.toJson()), 
        headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    return Parking.fromJson(json); */
    // add parking to Firestore under the logged-in user
    await FirebaseFirestore.instance
    .collection('persons')
    .doc(credential?.uid)
    .collection('parkings')
    .doc(parking.id)
    .set(parking.toJson());
    return parking;
  }

  Future<List<Parking>> getAll() async {
      /* final url = Uri.parse('$baseUrl/parkings');
      Response response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },);
      final json = await jsonDecode(response.body); // decoded json list
      final List<Parking> parkings = (json as List<dynamic>).map((e) => Parking.fromJson(e)).toList(); */
      // get all parkings from Firestore under the logged-in user
      final snapshot = await FirebaseFirestore.instance
          .collection('persons')
          .doc(credential?.uid)
          .collection('parkings')
          .get();
          final List<Parking> parkings = snapshot.docs
          .map((doc) => Parking.fromJson(doc.data()))
          .toList();

    return parkings;
    }
  
  
  Future<Parking?> getById(String vehicleId) async {
    /* final url = Uri.parse('$baseUrl/parkings/$vehicleId');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);

      if (response.statusCode == 200) {
        if (response.body.trim() == 'null') {
          return null;
        }
        final json = jsonDecode(response.body); // decoded json
      return Parking.fromJson(json);
      } else {
        return null;
      } */
    // get parking by id from Firestore under the logged-in user
    final snapshot = await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('parkings')
        .doc(vehicleId)
        .get();
    if (snapshot.exists) {
      final json = snapshot.data();
      if (json != null) {
      return Parking.fromJson(json);
    } else {
      throw Exception('Parking not found');   
    }
    } else {
      return null;
    }
  }

  Future<Parking> update(Parking parking) async {
    /* final url = Uri.parse('$baseUrl/parkings/${parking.id}');
    Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Parking.fromJson(json); */
    // update parking in Firestore under the logged-in user
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('parkings')
        .doc(parking.id)
        .update(parking.toJson());
    return parking;
  }
  
  Future<Parking?> delete(String id) async {
    /* final url = Uri.parse('$baseUrl/parkings/$id');
    Response response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      if (response.body.trim() == 'null') {
        return null;
      }
    }
    final json = await jsonDecode(response.body); // decoded json
    return Parking.fromJson(json); */
    // delete parking from Firestore under the logged-in user
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('parkings')
        .doc(id)
        .delete();
    return null; // Return null after deletion
  }
}