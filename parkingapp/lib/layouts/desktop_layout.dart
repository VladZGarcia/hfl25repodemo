import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class DesktopLayout extends StatefulWidget {
  final Widget map;
  final Widget content;
  final ValueNotifier<ThemeMode> themeNotifier;
  final Function(int) onIndexChanged;
  final int currentIndex;

    const DesktopLayout({
    super.key,
    required this.map,
    required this.content,
    required this.themeNotifier,
    required this.onIndexChanged,
    required this.currentIndex,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: NavigationRail(
              selectedIndex: widget.currentIndex, // Use the passed index
              onDestinationSelected: widget.onIndexChanged, // Use the callback
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Parking'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.ad_units_sharp),
                  label: Text('Tickets'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.directions_car_filled_outlined),
                  label: Text('Vehicles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_box_outlined),
                  label: Text('Account'),
                ),
              ],
            ),
          ),
          // Map and Content
          Expanded(
            child: Row(
              children: [
                Expanded(child: widget.map),
                Stack(
                  children: [
                  SizedBox(
                    width: 500, // Fixed width
                    child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                            constraints.maxHeight - 32, // Account for padding
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: widget.content,
                        ),
                        ),
                      );
                      },
                    ),
                    ),
                  ),
                  Positioned(
                    bottom: 26,
                    right: 26,
                    child: widget.currentIndex == 2
                    ? FloatingActionButton(
                        onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final uuid = Uuid();

                        String registrationNumber = '';
                        String loggedInUserId =
                            "9f7efa38-d2e4-478d-8283-6e2b08896269";
                        String ownerName = 'loggedInUser.name';
                        int ownerPersonId = 0123456789;

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
                                    id: loggedInUserId,
                                    name: ownerName,
                                    personId: ownerPersonId,
                                  ),
                                  ),
                                );
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vehicle added successfully!'),
                                  ),
                                ); 
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
                      )
                    : const SizedBox(),
                  ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
