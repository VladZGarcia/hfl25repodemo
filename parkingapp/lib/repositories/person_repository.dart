import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class PersonRepository {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid || Platform.isIOS) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  List<Person> persons = [];

  Future<Person> addPerson(Person person) async {
    await FirebaseFirestore.instance
        .collection('persons')
        .doc(person.id)
        .set(person.toJson());
    return person;
  }

  Future<List<Person>> getAll() async {
    final snapshot = await FirebaseFirestore.instance.collection('persons').get();
    final List<Person> persons = snapshot.docs
        .map((doc) => Person.fromJson(doc.data()))
        .toList();
    return persons;
  }

  Future<Person?> getById(String uId) async {

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

    await FirebaseFirestore.instance
        .collection('persons')
        .doc(person.id)
        .update(person.toJson());
    return person;
  }

  Future<Person?> delete(String? id) async {

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
