import 'dart:io';
import '../models/person.dart';
import '../repositories/person_repository.dart';

void handlePersons(PersonRepository repo) {
  while (true) {
    print('\nPerson handling. How can I help you?');
    print('1. Create person.');
    print('2. Show persons.');
    print('3. Update person.');
    print('4. Delete person.');
    print('5. Back to Main menu.');
    stdout.write('Choose alternative (1-5): ');

    var choice = stdin.readLineSync();
    switch (choice) {
      case '1':
        _createPerson(repo);
        break;
      case '2':
        _showAllPerson(repo);
        break;
      case '3':
        _updatePerson(repo);
        break;
      case '4':
        _deletePerson(repo);
        break;
      case '5':
        return;
      default:
        print('Not valid, try again.');
    }
  }
}

void _createPerson(PersonRepository repo) {
  stdout.write('Enter name: ');
  var name = stdin.readLineSync();
  stdout.write('Enter ID: ');
  var idNr = stdin.readLineSync();

  if (name != null && idNr != null) {
    var person = Person(name, idNr);
    repo.addPerson(person);
    print('Person created: $name, $idNr');
  } else {
    print('Invalid input, try again.');
  }
}

void _showAllPerson(PersonRepository repo) {
  var persons = repo.getAll();
  if (persons.isEmpty) {
    print('No persons found!');
  } else {
    print('List of persons:');
    for (var person in persons) {
      print('Name: ${person.name}, IDnr: ${person.id}');
    }
  }
}

void _updatePerson(PersonRepository repo) {
  stdout.write('Input ID number to update: ');
  var idNr = stdin.readLineSync();
  var person = repo.getById(idNr ?? '');

  if (person != null) {
    stdout.write('New Name (current name: ${person.name}):');
    var newName = stdin.readLineSync();
    if (newName != null && newName.isNotEmpty) {
      person.name = newName;
      repo.update(person);
      print('Person updated: ${person.name}, ${person.id}');
    } else {
      print('Name not valid.');
    }
  } else {
    print('Person with ID $idNr not found.');
  }
}

void _deletePerson(PersonRepository repo) {
  stdout.write('Input ID for Person to delete: ');
  var idNr = stdin.readLineSync();
  var person = repo.getById(idNr ?? '');

  if (person != null) {
    repo.delete(idNr ?? '');
    print('Person deleted: ${person.name}, ${person.id}');
  } else {
    print('Person with ID $idNr not found');
  }
}
