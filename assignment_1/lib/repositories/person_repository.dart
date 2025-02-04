import '../models/person.dart';

class PersonRepository {
  List<Person> persons = [];

  void addPerson(Person person) => persons.add(person);
  List<Person> getAll() => persons;
  Person? getById(String id) => persons.firstWhere((p) => p.id == id,
      orElse: () => throw Exception('Person not found'));
  void update(Person person) {
    var index = persons.indexWhere((p) => p.id == person.id);
    if (index != -1) persons[index] = person;
  }
  void delete(String id) => persons.removeWhere((p) => p.id == id);
}
