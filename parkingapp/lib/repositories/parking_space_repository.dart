import 'dart:convert';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

class ParkingSpaceRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
  List<Parkingspace> parkingSpaces = [];

  Future<Parkingspace> addParkingSpace(Parkingspace parkingspace) async {
    /* final url = Uri.parse('$baseUrl/parking_spaces');

    http.Response response = await http.post(url,
        body: jsonEncode(parkingspace.toJson()), 
        headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    
    return Parkingspace.fromJson(json); */
    // add parking space to Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    await FirebaseFirestore.instance
        .collection('parking_spaces')
        .add(parkingspace.toJson());
    return parkingspace;
  }

  Future<List<Parkingspace>> getAll() async {
    /* final url = Uri.parse('$baseUrl/parking_spaces');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
    final json = await jsonDecode(response.body); // decoded json list
    final List<Parkingspace> parkingSpaces = (json as List<dynamic>).map((e) => Parkingspace.fromJson(e)).toList(); */
    // get all parking spaces from Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('parking_spaces')
        .get();
    final List<Parkingspace> parkingSpaces = snapshot.docs
        .map((doc) => Parkingspace.fromJson(doc.data()))
        .toList();
    return parkingSpaces;
  }

  Future<Parkingspace?> getById(String spaceId) async {
    /* final url = Uri.parse('$baseUrl/parking_spaces/$spaceId');
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
      return Parkingspace.fromJson(json);
      } else {
        return null;
      } */
    // get parking space by ID from Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    final doc = await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(spaceId)
        .get();
    if (!doc.exists) {
      return null;
    }
    return Parkingspace.fromJson(doc.data()!);
  }

  Future<Parkingspace> update(Parkingspace parkingspace) async {
    /* final url = Uri.parse('$baseUrl/parking_spaces/${parkingspace.id}');
    Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json'},
      body: jsonEncode(parkingspace.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Parkingspace.fromJson(json); */
    // update parking space in Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(parkingspace.id)
        .update(parkingspace.toJson());
    return parkingspace;
  }

  Future<Parkingspace?> delete(String id) async {
    /* final url = Uri.parse('$baseUrl/parking_spaces/$id');
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
    return Parkingspace.fromJson(json); */
    // delete parking space from Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    await FirebaseFirestore.instance
        .collection('parking_spaces')
        .doc(id)
        .delete();
    return null;
  }
  
}
