import 'package:shared/shared.dart';

class PersonRepository {
  List<Person> persons = [];

  Future<Person> addPerson(Person person) async {
    persons.add(person);
    return person;}
  Future<List<Person>> getAll() async => persons;
  Future<Person?> getById(int id) async => persons
      .cast<Person?>()
      .firstWhere((p) => p?.personId == id, orElse: () => null);
  Future<void> update(Person person) async{
    var index = persons.indexWhere((p) => p.personId == person.personId);
    if (index != -1) persons[index] = person;
  }

  Future<void> delete(int id) async => persons.removeWhere((p) => p.personId == id);
}
