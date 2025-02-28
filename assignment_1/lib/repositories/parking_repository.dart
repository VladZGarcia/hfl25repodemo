import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class ParkingRepository {
  List<Parking> parkings = [];

  Future<Parking> addParking(Parking parking) async {
    final url = Uri.parse('http://localhost:8080/parkings');

    Response response = await http.post(url,
        body: jsonEncode(parking.toJson()), 
        headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    print('Parking created: ${json['id']}, vehicle registration number: ${json['vehicle']['registrationNumber']}, parking space id: ${json['parkingSpace']['id']}');
    return Parking.fromJson(json);
  }

  Future<List<Parking>> getAll() async {
    final url = Uri.parse('http://localhost:8080/parkings');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
    final json = await jsonDecode(response.body); // decoded json list
    final List<Parking> parkings = (json as List<dynamic>).map((e) => Parking.fromJson(e)).toList();

    return parkings;
    }
  
  
  Future<Parking?> getById(String id) async {
    final url = Uri.parse('http://localhost:8080/parkings/$id');
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
        throw Exception('Failed to load parking with id: $id');
      }
  }
  
  Future<Parking> update(Parking parking) async {
    final url = Uri.parse('http://localhost:8080/parkings/${parking.id}');
    Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json'},
      body: jsonEncode(parking.toJson()),
    );
    final json = await jsonDecode(response.body);
    
    return Parking.fromJson(json);
  }
  
  Future<Parking?> delete(String id) async {
    final url = Uri.parse('http://localhost:8080/parkings/$id');
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
    return Parking.fromJson(json);
  }
}