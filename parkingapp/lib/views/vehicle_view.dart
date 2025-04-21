import 'package:flutter/material.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';

class VehicleView extends StatefulWidget {
  const VehicleView({super.key});

  @override
  State<VehicleView> createState() => _VehicleViewState();
}

class _VehicleViewState extends State<VehicleView> {
  Future future = VehicleRepository().getAll();
  int _selectedIndex = -1;

  void refreshVehicles() {
    if (mounted) {
      setState(() {
        future = VehicleRepository().getAll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
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
                            onTap: () async {
                              if (mounted) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              }
                              await _handleVehicle(
                                context,
                                vehicle,
                                refreshVehicles,
                              );
                            },
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(vehicle.registrationNumber),
                                  subtitle: Text(vehicle.owner.name),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      _handleDeleteVehicle(
                                        context,
                                        vehicle,
                                        refreshVehicles,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color:
                                          _selectedIndex == index
                                              ? Colors.blue
                                              : null,
                                    ),
                                  ),
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
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error loading vehicles: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No vehicles available.'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }
}

Future<void> _handleVehicle(
  BuildContext context,
  vehicle,
  Function refreshCallback,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return VehicleDialog(vehicle: vehicle, refreshCallback: refreshCallback);
    },
  );
}

class VehicleDialog extends StatefulWidget {
  final vehicle;
  final Function refreshCallback;

  const VehicleDialog({
    Key? key,
    required this.vehicle,
    required this.refreshCallback,
  }) : super(key: key);

  @override
  _VehicleDialogState createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<VehicleDialog> {
  late TextEditingController registrationController;
  late TextEditingController ownerNameController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    registrationController = TextEditingController(
      text: widget.vehicle.registrationNumber,
    );
    ownerNameController = TextEditingController(
      text: widget.vehicle.owner.name,
    );
  }

  @override
  void dispose() {
    registrationController.dispose();
    ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit Vehicle' : 'Vehicle Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEditing) ...[
              Text('Registration Number: ${widget.vehicle.registrationNumber}'),
              Text('Owner Name: ${widget.vehicle.owner.name}'),
            ] else ...[
              TextField(
                controller: registrationController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: ownerNameController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!isEditing) ...[
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = true;
              });
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ] else ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                widget.vehicle.registrationNumber = registrationController.text;
                await VehicleRepository().update(widget.vehicle);
                Navigator.of(context).pop();
                widget.refreshCallback();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating vehicle: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ],
    );
  }
}

Future<void> _handleDeleteVehicle(
  BuildContext context,
  vehicle,
  Function refreshCallback,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Parking Tickets will allso be deleted! Are you sure you want to delete this vehicle?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                var parkingToDelete = await ParkingRepository().getById(
                  vehicle.id,
                );
                if (parkingToDelete != null) {
                  await ParkingRepository().delete(parkingToDelete.id);
                }

                await VehicleRepository().delete(vehicle.id);
                Navigator.of(context).pop();
                refreshCallback();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting vehicle: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
