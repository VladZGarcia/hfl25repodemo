import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/ticket/ticket_state.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
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
          'Not logged in',
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        if (state is TicketInitial) {
          context.read<TicketBloc>().add(LoadTickets());
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TicketLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TicketError) {
          /* if (state.message.contains("User not logged in") ||
              state.message.contains("not have permission")) {
                  return Center(
                    child: Text(
                      'Not logged in',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  );
                } */
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = state.tickets[index];
                    return TicketListItem(ticket: ticket);
                  },
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No tickets available'));
      },
    );
  }
}

class TicketListItem extends StatelessWidget {
  final Parking ticket;

  const TicketListItem({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _handleTicket(context, ticket);
          context.read<TicketBloc>().add(LoadTickets());
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
                    context.read<TicketBloc>().add(DeleteTicket(ticket.id));
                    setState(() {
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket deleted successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete parking'),
                ),
                TextButton(
                  onPressed: () async {
                    await ParkingRepository().update(ticket);
                    setState(() {
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ticket updated successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close and update'),
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
