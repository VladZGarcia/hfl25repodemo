import 'dart:convert';
import 'package:server/handlers/person_handlers.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';

void main() {
  group('Person Handlers', () {
    test('Create Person Handler', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/persons'),
        body: jsonEncode({'id': '11' ,'name': 'John Doe', 'personId': 1}),
        headers: {'Content-Type': 'application/json'},
      );

      final response = await createPersonHandler(request);

      expect(response.statusCode, equals(200));
      final responseBody = await response.readAsString();
      final jsonResponse = jsonDecode(responseBody);
      expect(jsonResponse['name'], equals('John Doe'));
      expect(jsonResponse['personId'], equals(1));
    });

    test('Get Persons Handler', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/persons'));

      final response = await getPersonsHandler(request);

      expect(response.statusCode, equals(200));
      final responseBody = await response.readAsString();
      final jsonResponse = jsonDecode(responseBody);
      expect(jsonResponse, isA<List>());
    });

    test('Get Person By ID Handler', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/persons/1'));

      final response = await getPersonByIdHandler(request);

      expect(response.statusCode, equals(200));
      final responseBody = await response.readAsString();
      final jsonResponse = jsonDecode(responseBody);
      expect(jsonResponse['personId'], equals(1));
    });

    test('Update Person Handler', () async {
      final request = Request(
        'PUT',
        Uri.parse('http://localhost:8080/persons/11'),
        body: jsonEncode({'id': '11','name': 'Jane Doe', 'personId': 1}),
        headers: {'Content-Type': 'application/json'},
      );

      final response = await updatePersonHandler(request);

      expect(response.statusCode, equals(200));
      final responseBody = await response.readAsString();
      final jsonResponse = jsonDecode(responseBody);
      expect(jsonResponse['name'], equals('Jane Doe'));
    });

    test('Delete Person Handler', () async {
      final request = Request('DELETE', Uri.parse('http://localhost:8080/persons/11'));

      final response = await deletePersonHandler(request);

      expect(response.statusCode, equals(200));
      final responseBody = await response.readAsString();
      final jsonResponse = jsonDecode(responseBody);
      expect(jsonResponse['personId'], equals(1));
    });
  });
}