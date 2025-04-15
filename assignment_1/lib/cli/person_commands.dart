import 'dart:io';
import 'package:assignment_1/cli/cli_utils.dart';
import 'package:shared/shared.dart';
import '../repositories/person_repository.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();
Future<void> handlePersons(PersonRepository repo) async {
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
        print('Creating person');
        await _createPerson(repo);

        break;
      case '2':
        print('Showing all persons');
        await _showAllPerson(repo);
        break;
      case '3':
        print('Updating person');
        await _updatePerson(repo);
        break;
      case '4':
        print('Deleting person');
        await _deletePerson(repo);
        break;
      case '5':
        return;
      default:
        print('\nNot valid, try again.');
    }
  }
}

Future<void> _createPerson(PersonRepository repo) async {
  stdout.write('\nEnter name: ');
  var name = stdin.readLineSync();
  stdout.write('Enter ID: ');
  var idNrInput = stdin.readLineSync();
  int? personId = int.tryParse(idNrInput!);

  if (name != null && personId != null) {
    var person = Person(id:uuid.v4(), name:name, personId:personId);
    Person? returned = await repo.addPerson(person);
    print('\nPerson created: ${returned.name}, ${returned.personId}');
  } else {
    print('\nInvalid input, try again.');
  }
}

Future<void> _showAllPerson(PersonRepository repo) async {
  var persons = await repo.getAll();
  if (persons.isEmpty) {
    print('\nNo persons found!');
  } else {
    print('\nList of persons:');
    for (var person in persons) {
      print('\nName: ${person.name}, IDnr: ${person.personId}');
    }
  }
}

Future<void> _updatePerson(PersonRepository repo) async {
  stdout.write('\nInput ID number to update: ');
  var idNrInput = stdin.readLineSync();
  int? idNr = int.tryParse(idNrInput!);
  
  if (isValid(idNr)) {
    Person? person = await repo.getById(idNr!);
    print('person id: ${person?.personId}');
    if (isValid(person)) {
      stdout.write('New ID (current ID: ${person?.personId}):');
      var newPersonIdInput = stdin.readLineSync();
      int? newPersonId = int.tryParse(newPersonIdInput!);
      stdout.write('New Name (current name: ${person?.name}):');
      var newName = stdin.readLineSync();
      if (isValid(newName)) {
        person?.name = newName!;
        person?.personId = newPersonId!;
        Person returned = await repo.update(person!);
        print('\nPerson updated: ${returned.name}, ${returned.personId}');
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

Future<void> _deletePerson(PersonRepository repo) async {
  stdout.write('\nInput ID for Person to delete: ');
  var idNrInput = stdin.readLineSync();
  int? idNr = int.tryParse(idNrInput!);
  if (isValid(idNr)) {
    Person? person = await repo.getById(idNr!);
    if (isValid(person)) {
      Person? returned = await repo.delete(person?.id);
      print('\nPerson deleted: ${returned?.name}, ${returned?.personId}');
    } else {
      print('\nPerson with ID "$idNrInput" not found');
    }
  } else {
    print('\nInvalid input, try again.');
  }
}
