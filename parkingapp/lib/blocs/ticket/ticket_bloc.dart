import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final ParkingRepository parkingRepository;

  TicketBloc({required this.parkingRepository}) : super(TicketInitial()) {
    on<LoadTickets>(_onLoadTickets);
    on<UpdateTicketEndTime>(_onUpdateTicketEndTime);
    on<DeleteTicket>(_onDeleteTicket);
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
      await parkingRepository.update(event.ticket);
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
      await parkingRepository.delete(event.ticketId);
      add(LoadTickets());
    } catch (e) {
      emit(TicketError(e.toString()));
    }
  }
}
