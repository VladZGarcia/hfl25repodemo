import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class ParkingSpaceRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  List<Parkingspace> parkingSpaces = [];

  Future<Parkingspace> addParkingSpace(Parkingspace parkingspace) async {
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
    
    final snapshot =
        await FirebaseFirestore.instance.collection('parking_spaces').get();
    final List<Parkingspace> parkingSpaces =
        snapshot.docs.map((doc) => Parkingspace.fromJson(doc.data())).toList();
    return parkingSpaces;
  }

  Future<Parkingspace?> getById(String spaceId) async {
    
    // get parking space by ID from Firestore
    final credential = FirebaseAuth.instance.currentUser;
    if (credential == null) {
      throw Exception("User not logged in");
    }
    final doc =
        await FirebaseFirestore.instance
            .collection('parking_spaces')
            .doc(spaceId)
            .get();
    if (!doc.exists) {
      return null;
    }
    return Parkingspace.fromJson(doc.data()!);
  }

  Future<Parkingspace> update(Parkingspace parkingspace) async {
    
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
