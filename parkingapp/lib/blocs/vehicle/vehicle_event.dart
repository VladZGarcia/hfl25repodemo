import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object> get props => [];
}

class LoadVehicles extends VehicleEvent {
  
}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const AddVehicle(this.vehicle);

  @override
  List<Object> get props => [vehicle];
}

class UpdateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object> get props => [vehicle];
}

class DeleteVehicle extends VehicleEvent {
  final String id;

  const DeleteVehicle(this.id);

  @override
  List<Object> get props => [id];
}