import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_state.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/ticket/ticket_state.dart';
import 'package:shared/shared.dart';

class TicketView extends StatelessWidget {
  final VoidCallback? onparkingAdded;

  const TicketView({super.key, this.onparkingAdded});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text(
          'Signup or login.',
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ParkingBloc, ParkingState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            // Don't need this anymore - tickets will update optimistically
            // context.read<TicketBloc>().add(LoadTickets());
          },
        ),
        BlocListener<TicketBloc, TicketState>(
          listenWhen: (previous, current) => previous != current,
          listener: (context, state) {
            print("TicketBloc state changed: ${state.runtimeType}");
            if (state is TicketLoaded) {
              print("Tickets count: ${state.tickets.length}");
            }
          },
        ),
      ],
      child: BlocBuilder<TicketBloc, TicketState>(
        buildWhen: (previous, current) {
          // Always rebuild for state changes
          print(
            "Previous tickets: ${previous is TicketLoaded ? (previous).tickets.length : 'loading'}",
          );
          print(
            "Current tickets: ${current is TicketLoaded ? (current).tickets.length : 'loading'}",
          );
          return true;
        },
        builder: (context, state) {
          if (state is TicketInitial) {
            context.read<TicketBloc>().add(LoadTickets());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is TicketLoaded) {
            if (state.tickets.isEmpty) {
              return const Center(
                child: Text(
                  'No parking tickets available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Tickets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Replace this ListView.builder with AnimatedList
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = state.tickets[index];
                      // Simple animation that doesn't delay visual updates
                      return AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 150,
                        ), // Shorter duration
                        color: Colors.transparent,
                        child: TicketListItem(ticket: ticket),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No tickets available'));
        },
      ),
    );
  }
}

class TicketListItem extends StatelessWidget {
  final Parking ticket;
  final bool isDeleting; // Add this line

  const TicketListItem({
    super.key,
    required this.ticket,
    this.isDeleting = false, // Add default value
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isDeleting ? 0.5 : 1.0, // Fade out when deleting
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await _handleTicket(context, ticket);
          },
          child: Column(
            key: ValueKey(ticket.id),
            children: [
              ListTile(
                title: Text(ticket.parkingSpace.adress),
                subtitle: Text(
                  ticket.endTime == null
                      ? 'Start: ${ticket.startTime.hour.toString().padLeft(2, '0')}:${ticket.startTime.minute.toString().padLeft(2, '0')}   Ends at: Ongoing'
                      : 'Start: ${ticket.startTime.hour.toString().padLeft(2, '0')}:${ticket.startTime.minute.toString().padLeft(2, '0')} Ends : ${ticket.endTime!.hour.toString().padLeft(2, '0')}:${ticket.endTime!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: Text('cost: ${calculateCost(ticket)}'),
                leading: const Icon(Icons.receipt),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }

  calculateCost(Parking ticket) {
    if (ticket.endTime != null) {
      final startMinutes = ticket.startTime.hour * 60 + ticket.startTime.minute;
      final endMinutes = ticket.endTime!.hour * 60 + ticket.endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;
      var costPerMinute =
          (ticket.parkingSpace.pricePerHour / 60); // Example cost per minute
      var cost = (durationMinutes * costPerMinute).toDouble();
      return cost.toStringAsFixed(2); // Format to 2 decimal places
    } else {
      final startMinutes = ticket.startTime.hour * 60 + ticket.startTime.minute;
      final currentTime = DateTime.now();
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final durationMinutes = currentMinutes - startMinutes;
      var costPerMinute =
          (ticket.parkingSpace.pricePerHour / 60); // Example cost per minute
      var cost = (durationMinutes * costPerMinute).toDouble();
      return cost.toStringAsFixed(2); // Format to 2 decimal places
    }
  }

  Future<void> _handleTicket(BuildContext context, Parking ticket) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ticket Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${ticket.id}'),
                  const SizedBox(height: 8),
                  Text(
                    'Vehicle Registration Number: ${ticket.vehicle.registrationNumber}',
                  ),
                  const SizedBox(height: 8),
                  Text('Parking Space Address: ${ticket.parkingSpace.adress}'),
                  const SizedBox(height: 8),
                  Text(
                    'Start Time: ${ticket.startTime.hour.toString().padLeft(2, '0')}:${ticket.startTime.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.endTime == null
                        ? 'End Time: Ongoing'
                        : 'End Time: ${ticket.endTime!.hour.toString().padLeft(2, '0')}:${ticket.endTime!.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 8),
                  Text('cost: ${calculateCost(ticket)}'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? pickedEndTime = await showTimePicker(
                        context: context,
                        initialEntryMode: TimePickerEntryMode.dial,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedEndTime != null) {
                        setState(() {
                          var newEndTime = pickedEndTime;
                          ticket.endTime = _convertTimeOfDayToDateTime(
                            newEndTime,
                          );
                        });
                      }
                    },
                    child: Text(
                      ticket.endTime == null
                          ? 'Ongoing parking or Select End Time'
                          : 'Change End Time?: ${ticket.endTime!.hour.toString().padLeft(2, '0')}:${ticket.endTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // 1. Show immediate visual feedback
                    Navigator.of(context).pop(); // Close dialog immediately

                    // 2. Show snackbar immediately
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deleting ticket and notifications...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    // 3. DEBUGGING
                    print("Delete button pressed for ticket: ${ticket.id}");

                    // 4. Then dispatch the event
                    context.read<TicketBloc>().add(DeleteTicket(ticket.id));
                  },
                  child: const Text('Delete parking'),
                ),
                TextButton(
                  onPressed: () async {
                    if (ticket.endTime != null) {
                      // Create a deep copy of the ticket to avoid reference issues
                      final updatedTicket = Parking(
                        ticket.id,
                        ticket.vehicle,
                        ticket.parkingSpace,
                        ticket.startTime,
                        ticket.endTime,
                      );

                      // IMPORTANT: Add proper debug message
                      print(
                        "Updating ticket: ${updatedTicket.id} with end time: ${updatedTicket.endTime}",
                      );

                      // Dispatch the update event with just the ticket
                      context.read<TicketBloc>().add(
                        UpdateTicketEndTime(updatedTicket),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket updated successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket is ongoing, don\'t forget to end parking!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close /update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime _convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}
