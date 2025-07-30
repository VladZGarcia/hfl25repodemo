import 'dart:convert';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class PersonRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  List<Person> persons = [];

  Future<Person> addPerson(Person person) async {
    /* final url = Uri.parse('$baseUrl/persons');

    Response response = await http.post(
      url,
      body: jsonEncode(person.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body);
    return Person.fromJson(json); */
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(person.id)
        .set(person.toJson());
    return person;
  }

  Future<List<Person>> getAll() async {
    /* final url = Uri.parse('$baseUrl/persons');
    Response response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    final json = await jsonDecode(response.body); // decoded json list
    final List<Person> persons =
        (json as List<dynamic>).map((e) => Person.fromJson(e)).toList(); */
    final snapshot = await FirebaseFirestore.instance.collection('persons').get();
    final List<Person> persons = snapshot.docs
        .map((doc) => Person.fromJson(doc.data()))
        .toList();
    return persons;
  }

  Future<Person?> getById(String uId) async {
    /* final url = Uri.parse('$baseUrl/persons/$personId');
    try {
      Response response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == 'null') {
          return null;
        }
        final json = jsonDecode(response.body); // decoded json
        return Person.fromJson(json);
      } else {
        throw Exception(
          'Failed to load person with id: $personId. StatusCode: ${response.statusCode}',
        );
      }
    } catch (e) {
      return null;
    } */

    final document =
        await FirebaseFirestore.instance
            .collection('persons')
            .doc(uId)
            .get();

    if (document.exists) {
      final json = document.data();
      if (json != null) {
        return Person.fromJson(json);
      }
    } else {
      throw Exception('Person with id $uId not found');
    }
    return null;
  }

  Future<Person> update(Person person) async {
    /* final url = Uri.parse('$baseUrl/persons/${person.id}');
    Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    final json = await jsonDecode(response.body); // decoded json
    return Person.fromJson(json); */

    await FirebaseFirestore.instance
        .collection('persons')
        .doc(person.id)
        .update(person.toJson());
    return person;
  }

  Future<Person?> delete(String? id) async {
    /* final url = Uri.parse('$baseUrl/persons/$id');
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
    return Person.fromJson(json); */

    final personToDelete = await getById(id!);
    if (personToDelete != null) {
      await FirebaseFirestore.instance
          .collection('persons')
          .doc(id)
          .delete();
      return personToDelete;
    }
    return null;
  }
}
