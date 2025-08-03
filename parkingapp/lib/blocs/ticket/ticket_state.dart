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
  final bool isDeleting; // Add this line
  final String? deletingTicketId; // Add this line - optional but helpful

  const TicketLoaded(
    this.tickets, {
    this.isDeleting = false, // Add this default parameter
    this.deletingTicketId, // Add this optional parameter
  });

  @override
  List<Object?> get props => [tickets, isDeleting, deletingTicketId]; // Update props

  // Add this copyWith method
  TicketLoaded copyWith({
    List<Parking>? tickets,
    bool? isDeleting,
    String? deletingTicketId,
  }) {
    return TicketLoaded(
      tickets ?? this.tickets,
      isDeleting: isDeleting ?? this.isDeleting,
      deletingTicketId: deletingTicketId ?? this.deletingTicketId,
    );
  }
}

class TicketError extends TicketState {
  final String message;

  const TicketError(this.message);

  @override
  List<Object> get props => [message];
}
