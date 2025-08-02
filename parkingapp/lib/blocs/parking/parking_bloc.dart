import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:parkingapp/main.dart';
import 'package:parkingapp/repositories/notification_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/parking_space_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  }

  Future<void> _onLoadParkingSpaces(
    LoadParkingSpaces event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          error: "User not logged in",
          isLoading: false,
          parkingSpaces: [],
        ),
      );
      return;
    }
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

      // Only schedule notification if endTime is after startTime
      if (event.endTime != null) {
        final startMinutes = event.startTime.hour * 60 + event.startTime.minute;
        final endMinutes = event.endTime!.hour * 60 + event.endTime!.minute;
        if (endMinutes > startMinutes) {
          // Convert TimeOfDay to DateTime for today
          final now = DateTime.now();
          var scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            event.endTime!.hour,
            event.endTime!.minute,
          );

          // If the scheduled time is in the past (like if user picks a time earlier today),
          // add one day to schedule it for tomorrow
          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }

          // Add a 5-minute warning before end time
          //final reminderTime = scheduledTime.subtract(
          //  const Duration(minutes: 1),
          //);

          // In your ParkingBloc, temporarily modify the reminder time for testing:
          final reminderTime = DateTime.now().add(const Duration(seconds: 15));

          print('Scheduling notification for parking ${parking.id}');
          print('Current time: ${DateTime.now()}');
          print('Reminder time: $reminderTime');

          await scheduleParkedNotifications(
            vehicleRegistration: event.vehicle.registrationNumber,
            parkingSpace: event.parkingSpace.adress,
            startTime: event.startTime,
            endTime: event.endTime!,
            parkingId: parking.id,
          );
          /* await realDeviceNotificationDemo(
            vehicleRegistration: event.vehicle.registrationNumber,
            parkingSpace: event.parkingSpace.adress,
            parkingId: parking.id,
          ); */
          /* await testEmulatorNotifications(); */
          /* await emulatorSequentialNotifications(); */

          // Add immediate test notification
          /* await notificationsPlugin.show(
            999, // different ID
            'Immediate Test 1',
            'This should appear right away',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'test_channel',
                'Test Channel',
                channelDescription: 'For testing notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          ); */
        }
      }

      await parkingRepository.addParking(parking);
      emit(const ParkingState());
      add(LoadParkingSpaces());
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
    // Do NOT auto-load parking spaces after reset, only load when user is logged in
  }

  double _calculateCost(TimeOfDay startTime, TimeOfDay endTime, double price) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final durationMinutes = endMinutes - startMinutes;
    final costPerMinute = price / 60;
    return (durationMinutes * costPerMinute).toDouble();
  }
}
