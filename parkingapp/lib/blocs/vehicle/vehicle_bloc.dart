import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onLoadVehicles(LoadVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    try {
      final vehicles = await vehicleRepository.getAll();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    try {
      await vehicleRepository.addVehicle(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<VehicleState> emit) async {
    try {
      await vehicleRepository.update(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    try {
      await vehicleRepository.delete(event.id);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}