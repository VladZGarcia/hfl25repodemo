import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:shared/shared.dart';

class TicketView extends StatefulWidget {
  const TicketView({super.key});

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ParkingRepository().getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      snapshot.data!.map((ticket) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(ticket.parkingSpace.adress),
                              subtitle: Text(
                                ticket.endTime == null
                                ? 'Start: ${ticket.startTime.hour.toString().padLeft(2, '0')}:${ticket.startTime.minute.toString().padLeft(2, '0')}   Ends at: Ongoing'
                                :'Start: ${ticket.startTime.hour.toString().padLeft(2, '0')}:${ticket.startTime.minute.toString().padLeft(2, '0')} Ends : ${ticket.endTime!.hour.toString().padLeft(2, '0')}:${ticket.endTime!.minute.toString().padLeft(2, '0')}'),
                              
                              trailing: Text(
                                'cost: ${calculateCost(ticket)}'),
                              leading: const Icon(Icons.receipt),
                            ),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading tickets: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  calculateCost(Parking ticket) {
    if (ticket.endTime != null) {
      final startMinutes = ticket.startTime.hour * 60 + ticket.startTime.minute;
      final endMinutes = ticket.endTime!.hour * 60 + ticket.endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;
      var costPerMinute = (ticket.parkingSpace.pricePerHour / 60); // Example cost per minute
      var cost = (durationMinutes * costPerMinute).toDouble();
      return cost.toStringAsFixed(2); // Format to 2 decimal places
    } else {
      final startMinutes = ticket.startTime.hour * 60 + ticket.startTime.minute;
      final currentTime = DateTime.now();
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final durationMinutes = currentMinutes - startMinutes;
      var costPerMinute = (ticket.parkingSpace.pricePerHour / 60); // Example cost per minute
      var cost = (durationMinutes * costPerMinute).toDouble();
      return cost.toStringAsFixed(2); // Format to 2 decimal places
    }

  }
}
