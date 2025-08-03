import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class LoadTickets extends TicketEvent {}

class UpdateTicketEndTime extends TicketEvent {
  final Parking ticket;

  const UpdateTicketEndTime(this.ticket);

  @override
  List<Object> get props => [ticket];
}

class DeleteTicket extends TicketEvent {
  final String ticketId;

  const DeleteTicket(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}

class ResetTickets extends TicketEvent {
  @override
  List<Object> get props => [];
}

class TicketAdded extends TicketEvent {
  final Parking newTicket;

  const TicketAdded(this.newTicket);

  @override
  List<Object?> get props => [newTicket];
}

class TicketUpdated extends TicketEvent {
  final List<Parking> tickets;

  const TicketUpdated(this.tickets);

  @override
  List<Object> get props => [tickets];
}
