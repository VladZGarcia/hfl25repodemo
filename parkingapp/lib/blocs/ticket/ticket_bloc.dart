import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/notification_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final ParkingRepository parkingRepository;

  TicketBloc({required this.parkingRepository}) : super(TicketInitial()) {
    on<LoadTickets>(_onLoadTickets);
    on<UpdateTicketEndTime>(_onUpdateTicketEndTime);
    on<DeleteTicket>(_onDeleteTicket);
    on<ResetTickets>(_onResetTickets);
  }

  Future<void> _onLoadTickets(
    LoadTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketLoading());
    try {
      final tickets = await parkingRepository.getAll();
      emit(TicketLoaded(tickets));
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onUpdateTicketEndTime(
    UpdateTicketEndTime event,
    Emitter<TicketState> emit,
  ) async {
    try {
      // First, cancel all existing notifications for this ticket
      await cancelParkedNotifications(event.ticket.id);

      // Update the ticket in the database
      await parkingRepository.update(event.ticket);

      // Now schedule new notifications with the updated time
      if (event.ticket.endTime != null) {
        await scheduleParkedNotifications(
          vehicleRegistration: event.ticket.vehicle.registrationNumber,
          parkingSpace: event.ticket.parkingSpace.adress,
          startTime: event.ticket.startTime,
          endTime: event.ticket.endTime!,
          parkingId: event.ticket.id,
        );

        print(
          'Notifications rescheduled for ticket ${event.ticket.id} with new end time: ${event.ticket.endTime}',
        );
      }

      // Reload tickets
      add(LoadTickets());
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onDeleteTicket(
    DeleteTicket event,
    Emitter<TicketState> emit,
  ) async {
    try {
      await cancelParkedNotifications(event.ticketId);
      await parkingRepository.delete(event.ticketId);
      add(LoadTickets());
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }

  Future<void> _onResetTickets(
    ResetTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketInitial());
  }
}
