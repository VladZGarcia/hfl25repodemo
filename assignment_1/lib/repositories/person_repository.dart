import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared/shared.dart';
import 'package:http/http.dart' as http;

class PersonRepository {
  List<Person> persons = [];

  Future<Person?> addPerson(Person person) async {
    final url = Uri.parse('http://localhost:8080/person');

    Response response = await http.post(url,
       body: jsonEncode(person.toJson()), 
       headers: {
      'Content-Type': 'application/json',
    });
    final json = await jsonDecode(response.body);
    print(json);
    return Person.fromJson(json);
    }
  
  Future<List<Person>> getAll() async  {
    final url = Uri.parse('http://localhost:8080/person');
    Response response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },);
    final json = await jsonDecode(response.body); // decoded json list
    final List<Person> persons = (json as List<dynamic>).map((e) => Person.fromJson(e)).toList();
    
    return persons;
    }

  Future<Person?> getById(int id) async => persons
      .cast<Person?>()
      .firstWhere((p) => p?.personId == id, orElse: () => null);
  Future<void> update(Person person) async{
    var index = persons.indexWhere((p) => p.personId == person.personId);
    if (index != -1) persons[index] = person;
  }

  Future<void> delete(int id) async => persons.removeWhere((p) => p.personId == id);
}
