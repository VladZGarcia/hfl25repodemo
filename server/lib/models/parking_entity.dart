import 'package:server/repositories/parking_space_repository.dart';
import 'package:server/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';

class ParkingEntity {
  final String id;
  final String vehicleId;
  final String parkingSpaceId;
  final DateTime startTime;
  final DateTime? endTime;

  ParkingEntity(
    {required this.id,
   required this.vehicleId, 
   required this.parkingSpaceId, 
   required this.startTime, 
   required this.endTime});

  //tojson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'parkingSpaceId': parkingSpaceId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
  //fromjson
  factory ParkingEntity.fromJson(Map<String, dynamic> json) {
    return ParkingEntity(
      id: json['id'],
      vehicleId: json['vehicleId'],
      parkingSpaceId: json['parkingSpaceId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    );
  }

  Future<Parking> toModel() async {
    final vehicleEntities = await VehicleRepository().getAll();
    final vehicleEntity = vehicleEntities.firstWhere((element) => element.id == vehicleId);
    final vehicle = await vehicleEntity.toModel();
    final parkingSpaces = await ParkingSpaceRepository().getAll();
    final parkingSpace = parkingSpaces.firstWhere((element) => element.id == parkingSpaceId);
    return Parking(id, vehicle, parkingSpace, startTime, endTime);
  }
}

extension EntityConversion on Parking {
  ParkingEntity toEntity() {
    return ParkingEntity(
      id: id,
      vehicleId: vehicle.id,
      parkingSpaceId: parkingSpace.id,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
