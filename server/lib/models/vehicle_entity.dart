import 'package:server/repositories/person_repository.dart';
import 'package:shared/shared.dart';

class VehicleEntity {
  final String id;
  final String registrationNumber;
  final String ownerId;

  VehicleEntity(
      {required this.id,
      required this.registrationNumber,
      required this.ownerId});

  // tojson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'ownerId': ownerId,
    };
  }

  // fromjson
  factory VehicleEntity.fromJson(Map<String, dynamic> json) {
    return VehicleEntity(
      id: json['id'],
      registrationNumber: json['registrationNumber'],
      ownerId: json['ownerId'],
    );
  }

  Future<Vehicle> toModel() async {
    final owners = await PersonRepository().getAll();
    final owner = owners.firstWhere((element) => element.id == ownerId);
    return Vehicle(id, registrationNumber, owner);
  }
}

extension EntityConversion on Vehicle {
  VehicleEntity toEntity() {
    return VehicleEntity(
      id: id,
      registrationNumber: registrationNumber,
      ownerId: owner.id,
    );
  }
}
