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
  final DateTime endTime;

  const UpdateTicketEndTime(this.ticket, this.endTime);

  @override
  List<Object> get props => [ticket, endTime];
}

class DeleteTicket extends TicketEvent {
  final String ticketId;

  const DeleteTicket(this.ticketId);

  @override
  List<Object> get props => [ticketId];
}
