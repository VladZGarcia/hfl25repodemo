import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkingSpaces extends ParkingEvent {}

class SelectParkingSpace extends ParkingEvent {
  final Parkingspace parkingSpace;
  final int index;

  const SelectParkingSpace(this.parkingSpace, this.index);

  @override
  List<Object?> get props => [parkingSpace, index];
}

class SelectVehicleEvent extends ParkingEvent {
  final Vehicle selectedVehicle;

  const SelectVehicleEvent(this.selectedVehicle);

  @override
  List<Object?> get props => [selectedVehicle];
}

class AddParkingEvent extends ParkingEvent {
  final Vehicle vehicle;
  final Parkingspace parkingSpace;
  final DateTime startTime;
  final DateTime? endTime;

  const AddParkingEvent({
    required this.vehicle,
    required this.parkingSpace,
    required this.startTime,
    this.endTime,
  });

  @override
  List<Object?> get props => [vehicle, parkingSpace, startTime, endTime];
}

class UpdateParkingTimeEvent extends ParkingEvent {
  final TimeOfDay endTime;

  const UpdateParkingTimeEvent(this.endTime);

  @override
  List<Object> get props => [endTime];
}

class ResetParkingEvent extends ParkingEvent {
  @override
  List<Object?> get props => [];
}

/* class UpdateEndTime extends ParkingEvent {
  final TimeOfDay endTime;

  const UpdateEndTime(this.endTime);

  @override
  List<Object?> get props => [endTime];
} */
/* class AddParking extends ParkingEvent {
  final Parking parking;

  const AddParking(this.parking);

  @override
  List<Object?> get props => [parking];
} */
