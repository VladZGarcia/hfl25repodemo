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
        print('\nNot valid, try again.');
    }
  }
}

void _createPerson(PersonRepository repo) {
  stdout.write('\nEnter name: ');
  var name = stdin.readLineSync();
  stdout.write('Enter ID: ');
  var idNrInput = stdin.readLineSync();
  int? idNr = int.tryParse(idNrInput!);

  if (name != null && idNr != null) {
    var person = Person(name, idNr);
    repo.addPerson(person);
    print('\nPerson created: $name, $idNr');
  } else {
    print('\nInvalid input, try again.');
  }
}

void _showAllPerson(PersonRepository repo) {
  var persons = repo.getAll();
  if (persons.isEmpty) {
    print('\nNo persons found!');
  } else {
    print('\nList of persons:');
    for (var person in persons) {
      print('\nName: ${person.name}, IDnr: ${person.id}');
    }
  }
}

void _updatePerson(PersonRepository repo) {
  stdout.write('\nInput ID number to update: ');
  var idNrInput = stdin.readLineSync();
  int? idNr = int.tryParse(idNrInput!);
  if (idNr != null) {
    var person = repo.getById(idNr);
    if (person != null) {
      stdout.write('New Name (current name: ${person.name}):');
      var newName = stdin.readLineSync();
      if (newName != null && newName.isNotEmpty) {
        person.name = newName;
        repo.update(person);
        print('\nPerson updated: ${person.name}, ${person.id}');
      } else {
        print('\nName not valid.');
      }
    } else {
      print('\nNo person found with this ID.');
    }
  } else {
    print('\nInvalid input. Enter a Valid ID number.');
  }
}

void _deletePerson(PersonRepository repo) {
  stdout.write('\nInput ID for Person to delete: ');
  var idNrInput = stdin.readLineSync();
  int? idNr = int.tryParse(idNrInput!);
  if (idNr != null) {
    var person = repo.getById(idNr);
    if (person != null) {
      repo.delete(idNr);
      print('\nPerson deleted: ${person.name}, ${person.id}');
    }else {
    print('\nPerson with ID "$idNrInput" not found');
  }
  } else {
    print('\nPerson with ID "$idNrInput" not found');
  }
}
