import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ParkingState extends Equatable {
  final List<Parkingspace> parkingSpaces;
  final Parkingspace? selectedParkingSpace;
  final int selectedIndex;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final double? cost;
  final bool isLoading;
  final String? error;
  final Vehicle? selectedVehicle;

  const ParkingState({
    this.parkingSpaces = const [],
    this.selectedParkingSpace,
    this.selectedIndex = -1,
    this.startTime,
    this.endTime,
    this.cost,
    this.isLoading = false,
    this.error,
    this.selectedVehicle,
  });

  ParkingState copyWith({
    List<Parkingspace>? parkingSpaces,
    Parkingspace? selectedParkingSpace,
    int? selectedIndex,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? cost,
    bool? isLoading,
    String? error,
    Vehicle? selectedVehicle,
  }) {
    return ParkingState(
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      selectedParkingSpace: selectedParkingSpace ?? this.selectedParkingSpace,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cost: cost ?? this.cost,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }

  @override
  List<Object?> get props => [
    parkingSpaces,
    selectedParkingSpace,
    selectedIndex,
    startTime,
    endTime,
    cost,
    isLoading,
    error,
    selectedVehicle,
  ];
}
