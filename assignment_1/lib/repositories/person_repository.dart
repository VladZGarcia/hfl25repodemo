import '../models/person.dart';

class PersonRepository {
  List<Person> persons = [];

  void addPerson(Person person) => persons.add(person);
  List<Person> getAll() => persons;
  Person? getById(int id) => persons
      .cast<Person?>()
      .firstWhere((p) => p?.personId == id, orElse: () => null);
  void update(Person person) {
    var index = persons.indexWhere((p) => p.personId == person.personId);
    if (index != -1) persons[index] = person;
  }

  void delete(int id) => persons.removeWhere((p) => p.personId == id);
}
