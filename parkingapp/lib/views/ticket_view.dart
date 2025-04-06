import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/parking_repository.dart';

class TicketView extends StatelessWidget {
  const TicketView({super.key});

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
                              subtitle: Text(ticket.startTime.toString()),
                              trailing: Text(ticket.endTime.toString()),
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
}
