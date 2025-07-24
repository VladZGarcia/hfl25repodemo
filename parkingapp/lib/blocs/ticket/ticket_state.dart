import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class TicketState extends Equatable {
  const TicketState();

  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketLoading extends TicketState {}

class TicketLoaded extends TicketState {
  final List<Parking> tickets;

  const TicketLoaded(this.tickets);

  @override
  List<Object> get props => [tickets];
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object> get props => [message];
}
