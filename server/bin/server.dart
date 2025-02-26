import 'dart:convert';
import 'dart:io';
import 'package:server/repositories/person_repository.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..post('/persons', _createPersonHandler)
  ..get('/persons', _getPersonsHandler)
  ..get('/persons/<personId>', _getPersonByIdHandler)
  ..put('/persons/<id>', _updatePersonHandler)
  ..delete('/persons/<personId>', _deletePersonHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

final personRepository = PersonRepository();

Future<Response> _createPersonHandler(Request request) async {
  final data = await request.readAsString();
  final json = jsonDecode(data);
  print('\njson: $json');
  Person person = Person.fromJson(json);
  print('Person created: ${person.name}, ${person.personId}');

  Person? createdPerson = await personRepository.addPerson(person);

  return Response.ok(jsonEncode(createdPerson.toJson()));
}

Future<Response> _getPersonsHandler(Request request) async {
  List<Person> persons = await personRepository.getAll();
  List<dynamic> personList = persons.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(personList));
}

Future<Response> _getPersonByIdHandler(Request request) async {
  String? personId = request.params['personId'];
  if (personId != null) {
    int? id = int.tryParse(personId);
    if (id != null) {
      Person? foundPerson = await personRepository.getById(id);
      return Response.ok(jsonEncode(foundPerson?.toJson()));
    } else {
      return Response.notFound('Person not found');
    }
  }
  return Response.notFound('Person not found');
}

Future<Response> _updatePersonHandler(Request request) async {
  String? idStr = request.params['id'];
  if (idStr != null) {
    final data = await request.readAsString();
    final json = jsonDecode(data);
    Person person = Person.fromJson(json);
    Person updatedPerson = await personRepository.update(idStr, person);
    return Response.ok(jsonEncode(updatedPerson.toJson()));
  }
  return Response.notFound('Person not found');
}

Future<Response> _deletePersonHandler(Request request) async {
  String? personIdStr = request.params['personId'];
  if (personIdStr != null) {
    int? personId = int.tryParse(personIdStr);
    if (personId != null) {
      Person removedPerson = await personRepository.delete(personId);
      return Response.ok(jsonEncode(removedPerson.toJson()));
    } else {
      return Response.notFound('Person not found');
    }
  }
  return Response.notFound('Person not found');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
