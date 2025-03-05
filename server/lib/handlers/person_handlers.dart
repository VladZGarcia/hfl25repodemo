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

  Person? createdPerson = await personRepo.add(person);

  return Response.ok(jsonEncode(createdPerson.toJson()));
}

Future<Response> getPersonsHandler(Request request) async {
  List<Person> persons = await personRepo.getAll();
  List<dynamic> personList = persons.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(personList));
}

Future<Response> getPersonByIdHandler(Request request) async {
  String? personId = request.params['personId'];

  if (personId == null || personId.isEmpty) {
    return Response.badRequest(
        body: 'Invalid request: Person ID must be provided.');
  }
  int? id = int.tryParse(personId);
  if (id == null) {
    return Response.badRequest(
        body: 'Invalid request: Person ID must be a number.');
  }

  try {
    Person? foundPerson = await personRepo.getById(id.toString());
    return Response.ok(jsonEncode(foundPerson.toJson()));
    } catch (e) {
    return Response.internalServerError(
        body: 'An error occurred while trying to get the person: ${e.toString()}');
  }
}

Future<Response> updatePersonHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Person person = Person.fromJson(json);
    Person updatedPerson = await personRepo.update(person.id, person);
    return Response.ok(jsonEncode(updatedPerson.toJson()));
  }
  return Response.notFound('Person not found');
}

Future<Response> deletePersonHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    try {
      Person removedPerson = await personRepo.delete(idStr);
      return Response.ok(jsonEncode(removedPerson.toJson()));
    } catch (e) {
      if (e.toString() == 'Exception: Person with ID "$idStr" not found') {
        return Response.notFound('Person with ID "$idStr" not found.');
      }
      return Response.internalServerError(
          body:
              'An error occurred while trying to delete the person: ${e.toString()}');
    }
  } else {
    return Response.badRequest(body: 'Invalid request: ID must be provided.');
  }
}
