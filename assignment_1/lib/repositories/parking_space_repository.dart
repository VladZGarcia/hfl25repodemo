import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class ParkingSpaceRepository {
  List<Parkingspace> parkingSpaces = [];

  Future<Parkingspace> addParkingSpace(Parkingspace parkingspace) async {
    final url = Uri.parse('http://localhost:8080/parking_spaces');

    Response response = await http.post(url,
        body: jsonEncode(parkingspace.toJson()), 
        headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    print('Parking space created: ${json['spaceId']}, ${json['adress']}');
    return Parkingspace.fromJson(json);
    }
  

  Future<List<Parkingspace>> getAll() async {
    final url = Uri.parse('http://localhost:8080/parking_spaces');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
    final json = await jsonDecode(response.body); // decoded json list
    final List<Parkingspace> parkingSpaces = (json as List<dynamic>).map((e) => Parkingspace.fromJson(e)).toList();
    
    return parkingSpaces;
  }

  Future<Parkingspace?> getById(String spaceId) async {
    final url = Uri.parse('http://localhost:8080/parking_spaces/$spaceId');
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
      }
  }

  Future<Parkingspace> update(Parkingspace parkingspace) async {
    final url = Uri.parse('http://localhost:8080/parking_spaces/${parkingspace.id}');
    Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json'},
      body: jsonEncode(parkingspace.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Parkingspace.fromJson(json);
  }

  Future<Parkingspace?> delete(String id) async {
    final url = Uri.parse('http://localhost:8080/parking_spaces/$id');
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
    return Parkingspace.fromJson(json);
  }
}
