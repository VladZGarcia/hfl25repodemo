import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/parking_space_repository.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class ParkingView extends StatefulWidget {
  const ParkingView({super.key});

  @override
  State<ParkingView> createState() => _ParkingViewState();
}

class _ParkingViewState extends State<ParkingView> {
  int _selectedIndex = -1;
  String? _selectedVehicleId;
  String? _selectedParkingSpaceId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ParkingSpaceRepository().getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Available Parkings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final parkingSpace = snapshot.data![index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          _handleParking(context);
                        });
                      },
                      child: Column(
                        key: ValueKey(parkingSpace.id),
                        children: [
                          ListTile(
                            title: Text(parkingSpace.adress),
                            subtitle: Text(parkingSpace.spaceId),
                            leading: Icon(
                              Icons.local_parking,
                              color:
                                  _selectedIndex == index ? Colors.blue : null,
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading parkingspaces: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No parkingsspaces available.'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _handleParking(BuildContext context) {
    return showDialog(
      context: context,

      builder: (context) {
        final uuid = Uuid();

        return AlertDialog(
          title: const Text('Add Parking'),

          content: FutureBuilder(
            future: VehicleRepository().getAll(),

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading vehicles: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No vehicles available.'));
              } else {
                return DropdownButton<String>(
                  value: _selectedVehicleId,

                  hint: const Text('Select a vehicle'),

                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVehicleId = newValue;
                    });
                  },

                  items:
                      snapshot.data!.map<DropdownMenuItem<String>>((vehicle) {
                        return DropdownMenuItem<String>(
                          value: vehicle.id,

                          child: Text(vehicle.registrationNumber),
                        );
                      }).toList(),
                );
              }
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                // Handle the add action here

                Navigator.of(context).pop();
              },

              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
