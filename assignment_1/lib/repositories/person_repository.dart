import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class PersonRepository {
  List<Person> persons =  [];

  Future<Person> addPerson(Person person) async {
    final url = Uri.parse('http://localhost:8080/persons');

    Response response = await http.post(url,
       body: jsonEncode(person.toJson()), 
       headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    print('Person created: ${json['name']}, ${json['personId']}');
    return Person.fromJson(json);
    }
  
  Future<List<Person>> getAll() async {
    final url = Uri.parse('http://localhost:8080/persons');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
    final json = await jsonDecode(response.body); // decoded json list
    final List<Person> persons = (json as List<dynamic>).map((e) => Person.fromJson(e)).toList();
    
    return persons;
    }

  Future<Person?> getById(int personId) async {
    final url = Uri.parse('http://localhost:8080/persons/$personId');
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
      return Person.fromJson(json);
      } else {
        throw Exception('Failed to load person with id: $personId');
      }
    }
    
  Future<Person> update(Person person) async {
    final url = Uri.parse('http://localhost:8080/persons/${person.id}');
    Response response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json'},
        body: jsonEncode(person.toJson()),);
    final json = await jsonDecode(response.body); // decoded json
    return Person.fromJson(json);
  }
  
  Future<Person?> delete(String? id) async {
    final url = Uri.parse('http://localhost:8080/persons/$id');
    Response response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
      if (response.statusCode != 200) {
        if (response.body.trim() == 'null') {
          return null;
        }
      }
    final json = await jsonDecode(response.body); // decoded json
    return Person.fromJson(json);
  }
}
