import 'package:server/repositories/file_repository.dart';
import 'package:shared/shared.dart';

class PersonRepository extends FileRepository<Person> {
  PersonRepository() : super('persons.json');

  @override
  Person fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return Person.fromJson(json);
  }

  @override
  String idFromType(Person person) {
    // TODO: implement idFromType
    return person.id;
  }
  @override
  String simpleIdFromType(Person person) {
    // TODO: implement idFromType
    return person.personId.toString();
  }

  @override
  Map<String, dynamic> toJson(Person person) {
    // TODO: implement toJson
    return person.toJson();
  }

  @override
  Future<Person> getById(String id) async {
    var persons = await readFile();
    for (var person in persons) {
      if (simpleIdFromType(person) == id) {
        return person;
      }
    }
    throw Exception('Person not found');
  }

  /* @override
  Future<Person> delete(String id) async {
    var persons = await readFile();
    for (var i = 0; i < persons.length; i++) {
      if (simpleIdFromType(persons[i]) == id) {
        Person removedPerson = persons.removeAt(i);
        await writeFile(persons);
        return removedPerson;
      }
    }
    throw Exception('Person not found');
  } */

/*   List<Person> persons = [];

  Future<Person> addPerson(Person person) async {
    persons.add(person);
    return person;
  }

  Future<List<Person>> getAll() async => persons;

  Future<Person?> getById(int personId) async => persons
      .cast<Person?>()
      .firstWhere((p) => p?.personId == personId, orElse: () => null);

  Future<Person> update(Person person) async {
    var index = persons.indexWhere((p) => p.id == person.id);
    if (index != -1) persons[index] = person;
    return person;
  }

  Future<Person> delete(int personId) async {
    Person removedPerson =
        persons.cast<Person>().firstWhere((p) => p.personId == personId);
    persons.removeWhere((p) => p.personId == personId);
    return removedPerson;
  } */
}
