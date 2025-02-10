import '../models/person.dart';

class PersonRepository {
  List<Person> persons = [];

  void addPerson(Person person) => persons.add(person);
  List<Person> getAll() => persons;
  Person? getById(int id) => persons.cast<Person?>().firstWhere((p) => p?.id == id, orElse: () => null);
  void update(Person person) {
    var index = persons.indexWhere((p) => p.id == person.id);
    if (index != -1) persons[index] = person;
  }
  void delete(int id) => persons.removeWhere((p) => p.id == id);
}
