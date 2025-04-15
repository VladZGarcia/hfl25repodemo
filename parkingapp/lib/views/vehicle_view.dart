import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: VehicleRepository().getAll(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Vehicles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vehicle = snapshot.data![index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                          _selectedIndex = index;
                        });
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(vehicle.registrationNumber),
                                subtitle: Text(vehicle.owner.name),
                                leading: Icon(
                                  Icons.directions_car,
                                  color:
                                      _selectedIndex == index
                                          ? Colors.blue
                                          : null,
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
                child: Text('Error loading vehicles: ${snapshot.error}'),
              );
            } else if(!snapshot.hasData || snapshot.data!.isEmpty){
              return const Center(child: Text('No vehicles available.'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Positioned(
          bottom: 6.0,
          right: 6.0,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final uuid = Uuid();

                  String registrationNumber = '';
                  String ownerName = 'loggedInUser.name';
                  int ownerId = 0123456789;

                  return AlertDialog(
                    title: const Text('Add Vehicle'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Registration Number',
                          ),
                          onChanged: (value) {
                            registrationNumber = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await VehicleRepository().addVehicle(
                            Vehicle(
                              uuid.v4(),
                              registrationNumber,
                              Person(
                                id: uuid.v4(),
                                name: ownerName,
                                personId: ownerId,
                              ),
                            ),
                          );
                          // Optionally, you can refresh the list of vehicles here
                          Navigator.of(context).pop();
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
