import 'package:shared/shared.dart';

class PersonRepository {
  List<Person> persons = [];

  Future<Person> addPerson(Person person) async {
    persons.add(person);
    return person;
  }

  Future<List<Person>> getAll() async => persons;

  Future<Person?> getById(int personId) async => persons
      .cast<Person?>()
      .firstWhere((p) => p?.personId == personId, orElse: () => null);
      
  Future<Person> update(String id,Person person) async {
    var index = persons.indexWhere((p) => p.id == person.id);
    if (index != -1) persons[index] = person;
    return person;
  }

  Future<Person> delete(int personId) async {
    Person removedPerson = persons.cast<Person>().firstWhere((p) => p.personId == personId);
    persons.removeWhere((p) => p.personId == personId);
    return removedPerson;
  }

}
