import 'package:assignment_1/models/person.dart';

class Vehicle {
  final String id;
  String registrationNumber;
  /* String type; */
  Person owner;

  Vehicle(this.id, this.registrationNumber, /* this.type, */ this.owner);
}
