import 'dart:convert';

import 'package:server/repositories/person_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

PersonRepository personRepo = PersonRepository();

Future<Response> createPersonHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  Person person = Person.fromJson(json);
  print('Person created: ${person.name}, ${person.personId}');

  Person? createdPerson = await personRepo.addPerson(person);

  return Response.ok(jsonEncode(createdPerson.toJson()));
}

Future<Response> getPersonsHandler(Request request) async {
  List<Person> persons = await personRepo.getAll();
  List<dynamic> personList = persons.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(personList));
}

Future<Response> getPersonByIdHandler(Request request) async {
  String? personId = request.params['personId'];
  if (personId != null) {
    int? id = int.tryParse(personId);
    if (id != null) {
      Person? foundPerson = await personRepo.getById(id);
      print('person found: $foundPerson');
      return Response.ok(jsonEncode(foundPerson?.toJson()));
    } else {
      return Response.notFound('Person not found');
    }
  }
  return Response.notFound('Person not found');
}

Future<Response> updatePersonHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Person person = Person.fromJson(json);
    Person updatedPerson = await personRepo.update(person);
    return Response.ok(jsonEncode(updatedPerson.toJson()));
  }
  return Response.notFound('Person not found');
}

Future<Response> deletePersonHandler(Request request) async {
  String? personIdStr = request.params['personId'];
  if (personIdStr != null) {
    int? personId = int.tryParse(personIdStr);
    if (personId != null) {
      Person removedPerson = await personRepo.delete(personId);
      return Response.ok(jsonEncode(removedPerson.toJson()));
    } else {
      return Response.notFound('Person not found');
    }
  }
  return Response.notFound('Person not found');
}