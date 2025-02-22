import 'package:assignment_1/models/person.dart';

class Vehicle {
  final String id;
  String registrationNumber;
  /* String type; */
  Person owner;

  Vehicle(this.id, this.registrationNumber, /* this.type, */ this.owner);

factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['id'],
      json['registrationNumber'],
      /* json['type'], */
      Person.fromJson(json['owner']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      /* 'type': type, */
      'owner': owner.toJson(),
    };
  }

}

