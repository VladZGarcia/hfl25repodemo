import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;
  final ParkingRepository parkingRepository;
  User? get credential => FirebaseAuth.instance.currentUser;

  VehicleBloc({
    required this.vehicleRepository,
    required this.parkingRepository,
  }) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<ResetVehicles>(_onResetVehicles);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      if (credential == null) {
        emit(VehicleError("User not logged in"));
        return;
      }
      final vehicles = await vehicleRepository.getAll();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      emit(VehicleLoading());
      // Add vehicle to the repository
      await vehicleRepository.addVehicle(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.update(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      // Delete all parkings for this vehicle
      final parkings = await parkingRepository.getAll();
      var parkingToDelete =
          parkings.where((parking) => parking.vehicle.id == event.id).toList();

      for (var parking in parkingToDelete) {
        await parkingRepository.delete(parking.id);
      }

      // Then delete the vehicle
      await vehicleRepository.delete(event.id);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onResetVehicles(
    ResetVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleInitial());
  }
}
