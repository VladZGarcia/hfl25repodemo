import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';

class VehicleView extends StatelessWidget {
  const VehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: VehicleRepository().getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Vehicles',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      snapshot.data!.map((vehicle) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(vehicle.registrationNumber),
                              subtitle: Text(vehicle.owner.name),
                              leading: const Icon(Icons.directions_car),
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
            child: Text('Error loading vehicles: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
