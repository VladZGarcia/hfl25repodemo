import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class ParkingRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

    User? get credential => FirebaseAuth.instance.currentUser;

  List<Parking> parkings = [];

  Future<Parking> addParking(Parking parking) async {
    await FirebaseFirestore.instance
    .collection('persons')
    .doc(credential?.uid)
    .collection('parkings')
    .doc(parking.id)
    .set(parking.toJson());
    return parking;
  }

  Future<List<Parking>> getAll() async {
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
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('parkings')
        .doc(parking.id)
        .update(parking.toJson());
    return parking;
  }
  
  Future<Parking?> delete(String id) async {
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(credential?.uid)
        .collection('parkings')
        .doc(id)
        .delete();
    return null; 
  }
}