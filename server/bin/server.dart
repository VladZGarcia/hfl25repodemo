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
  ..post('/person', _createPersonHandler)
  ..get('/person', _getPersonHandler);

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
  Person person = Person.fromJson(json);
  print('\nPerson created: ${person.name}, ${person.personId}');

  Person? created = await personRepository.addPerson(person);

  return Response.ok(jsonEncode(created.toJson()));
}

Future<Response> _getPersonHandler(Request request) async {
  List<Person> persons = await personRepository.getAll();
  List<dynamic> personList = persons.map((e) => e.toJson()).toList();
  return Response.ok(jsonEncode(personList));
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
