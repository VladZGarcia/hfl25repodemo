import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/notification_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:shared/shared.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final ParkingRepository parkingRepository;

  TicketBloc({required this.parkingRepository}) : super(TicketInitial()) {
    on<LoadTickets>(_onLoadTickets);
    on<UpdateTicketEndTime>(_onUpdateTicketEndTime);
    on<DeleteTicket>(_onDeleteTicket);
    on<ResetTickets>(_onResetTickets);
    on<TicketAdded>(_onTicketAdded);
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
      // Optimistic UI update
      if (state is TicketLoaded) {
        final currentState = state as TicketLoaded;

        // Create a new list with the updated ticket
        final updatedTickets =
            currentState.tickets.map((t) {
              // Replace the ticket with matching ID
              if (t.id == event.ticket.id) {
                return event.ticket;
              }
              return t;
            }).toList();

        // Immediately emit the updated state
        emit(TicketLoaded(updatedTickets));

        print("Ticket updated optimistically: ${event.ticket.id}");
      }

      // Then perform actual update in the background
      await parkingRepository.update(event.ticket);

      // Schedule notifications if needed
      /* if (event.ticket.endTime != null) {
        await scheduleParkedNotifications(
          vehicleRegistration: event.ticket.vehicle.registrationNumber,
          parkingSpace: event.ticket.parkingSpace.adress,
          startTime: event.ticket.startTime,
          endTime: event.ticket.endTime!,
          parkingId: event.ticket.id,
        );
      } */
    } catch (e) {
      print("Error updating ticket: $e");
      add(LoadTickets()); // Reload on error
    }
  }

  Future<void> _onDeleteTicket(
    DeleteTicket event,
    Emitter<TicketState> emit,
  ) async {
    try {
      print("Deleting ticket: ${event.ticketId}");

      // Optimistic UI update
      if (state is TicketLoaded) {
        final currentState = state as TicketLoaded;
        final updatedTickets =
            currentState.tickets
                .where((ticket) => ticket.id != event.ticketId)
                .toList();
        emit(TicketLoaded(updatedTickets));
      }

      // IMPORTANT: Wait for both operations to complete before proceeding
      await Future.wait([
        cancelParkedNotifications(event.ticketId),
        parkingRepository.delete(event.ticketId),
      ]);
    } catch (e) {
      print("Error deleting ticket: $e");
      // reload on error
      add(LoadTickets());
    }
  }

  Future<void> _onResetTickets(
    ResetTickets event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketInitial());
  }

  Future<void> _onTicketAdded(
    TicketAdded event,
    Emitter<TicketState> emit,
  ) async {
    try {
      // If tickets are already loaded, just add the new one optimistically
      if (state is TicketLoaded) {
        final currentState = state as TicketLoaded;
        // Create a new list with the new ticket added
        final updatedTickets = List<Parking>.from(currentState.tickets)
          ..add(event.newTicket);

        // Sort by newest first if needed
        updatedTickets.sort((a, b) => b.startTime.compareTo(a.startTime));

        // Immediately emit new state with the added ticket
        emit(TicketLoaded(updatedTickets));

        print("Ticket added optimistically: ${event.newTicket.id}");
      }
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
