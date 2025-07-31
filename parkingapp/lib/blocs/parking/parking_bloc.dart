import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/parking_space_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  final ParkingSpaceRepository parkingSpaceRepository;

  ParkingBloc({
    required this.parkingRepository,
    required this.parkingSpaceRepository,
  }) : super(const ParkingState()) {
    on<LoadParkingSpaces>(_onLoadParkingSpaces);
    on<SelectParkingSpace>(_onSelectParkingSpace);
    on<AddParkingEvent>(_onAddParkingEvent);
    on<SelectVehicleEvent>(_onSelectVehicle);
    on<UpdateParkingTimeEvent>(_onUpdateParkingTime);
    on<ResetParkingEvent>(_onResetStates);
    /* on<AddParking>(_onAddParking);
    on<UpdateEndTime>(_onUpdateEndTime); */
  }

  Future<void> _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final parkingSpaces = await parkingSpaceRepository.getAll();
      emit(state.copyWith(parkingSpaces: parkingSpaces, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
      print('Parking error1: ${e.toString()}');
    }
  }

  void _onSelectParkingSpace(
    SelectParkingSpace event,
    Emitter<ParkingState> emit,
  ) {
    emit(
      state.copyWith(
        selectedParkingSpace: event.parkingSpace,
        selectedIndex: event.index,
        startTime: TimeOfDay.now(),
      ),
    );
  }

  Future<void> _onAddParkingEvent(
    AddParkingEvent event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      final parking = Parking(
        const Uuid().v4(),
        event.vehicle,
        event.parkingSpace,
        event.startTime,
        event.endTime,
      );

      await parkingRepository.addParking(parking);
      emit(const ParkingState());
      add(LoadParkingSpaces());
      /* emit(
        state.copyWith(
          selectedParkingSpace: null,
          selectedVehicle: null,
          selectedIndex: -1,
          startTime: null,
          endTime: null,
          cost: null,
        ),
      ); */
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      print('Parking error2: ${e.toString()}');
    }
  }

  void _onUpdateParkingTime(
    UpdateParkingTimeEvent event,
    Emitter<ParkingState> emit,
  ) {
    emit(
      state.copyWith(
        endTime: event.endTime,
        cost: _calculateCost(
          state.startTime!,
          event.endTime,
          state.selectedParkingSpace!.pricePerHour.toDouble(),
        ),
      ),
    );
  }

  void _onSelectVehicle(SelectVehicleEvent event, Emitter<ParkingState> emit) {
    emit(state.copyWith(selectedVehicle: event.selectedVehicle, error: null));
  }

  void _onResetStates(ResetParkingEvent event, Emitter<ParkingState> emit) {
    emit(const ParkingState());
    add(LoadParkingSpaces());
  }

  double _calculateCost(TimeOfDay startTime, TimeOfDay endTime, double price) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    final costPerMinute = price / 60;
    return (durationMinutes * costPerMinute).toDouble();
  }
}

 /* Future<void> _onAddParking(
    AddParking event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      await parkingRepository.addParking(event.parking);
      emit(
        state.copyWith(
          selectedParkingSpace: null,
          selectedIndex: -1,
          startTime: null,
          endTime: null,
          cost: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  } */
  /* void _onUpdateEndTime(UpdateEndTime event, Emitter<ParkingState> emit) {
    final price = state.selectedParkingSpace?.pricePerHour ?? 0;
    final cost = _calculateCost(
      state.startTime!,
      event.endTime,
      price.toDouble(),
    );
    emit(state.copyWith(endTime: event.endTime, cost: cost));
  } */