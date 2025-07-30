import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_state.dart';
import 'package:shared/shared.dart';

class VehicleView extends StatelessWidget {
  final VoidCallback? onVehicleAdded;

  VehicleView({super.key, this.onVehicleAdded});
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleLoaded) {
          // Vehicles have been reloaded, now reload tickets
          context.read<TicketBloc>().add(LoadTickets());
        }
      },
      child: Stack(
        children: [
          BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              if (state is VehicleInitial) {
                context.read<VehicleBloc>().add(LoadVehicles());
                return const Center(child: CircularProgressIndicator());
              }

              if (state is VehicleLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is VehicleError) {
                if (state.message.contains("User not logged in")) {
                  return Center(
                    child: Text(
                      'Not logged in',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                );
              }

              if (state is VehicleLoaded) {
                if (state.vehicles.isEmpty) {
                  return Center(
                    child: Text(
                      'Add vehicles',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: ValueListenableBuilder<int>(
                    valueListenable: selectedIndexNotifier,
                    builder: (context, selectedIndex, _) {
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
                            itemCount: state.vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = state.vehicles[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    selectedIndexNotifier.value = index;
                                    _handleVehicle(context, vehicle);
                                  },
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(vehicle.registrationNumber),
                                        subtitle: Text(vehicle.owner.name),
                                        trailing: IconButton(
                                          onPressed: () {
                                            selectedIndexNotifier.value = index;
                                            _handleDeleteVehicle(
                                              context,
                                              vehicle,
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color:
                                                selectedIndex == index
                                                    ? Colors.blue
                                                    : null,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.directions_car,
                                          color:
                                              selectedIndex == index
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
                    },
                  ),
                );
              }
              return const Center(child: Text('No vehicles available'));
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _handleVehicle(BuildContext context, vehicle) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return VehicleDialog(vehicle: vehicle);
    },
  );
}

class VehicleDialog extends StatelessWidget {
  final Vehicle vehicle;

  final TextEditingController registrationController;
  final TextEditingController ownerNameController;
  final ValueNotifier<bool> isEditingNotifier = ValueNotifier<bool>(false);

  VehicleDialog({super.key, required this.vehicle})
    : registrationController = TextEditingController(
        text: vehicle.registrationNumber,
      ),
      ownerNameController = TextEditingController(text: vehicle.owner.name);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ValueListenableBuilder<bool>(
        valueListenable: isEditingNotifier,
        builder: (context, isEditing, child) {
          return Text(
            isEditing ? 'Edit Vehicle' : 'Vehicle Details',
            textAlign: TextAlign.center,
          );
        },
      ),
      content: SingleChildScrollView(
        child: ValueListenableBuilder<bool>(
          valueListenable: isEditingNotifier,
          builder: (context, isEditing, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing) ...[
                  Text('Registration Number: ${vehicle.registrationNumber}'),
                  Text('Owner Name: ${vehicle.owner.name}'),
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
            );
          },
        ),
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: isEditingNotifier,
          builder: (context, isEditing, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isEditing) ...[
                  TextButton(
                    onPressed: () {
                      isEditingNotifier.value = true;
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
                      if (registrationController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registration number cannot be empty',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      try {
                        vehicle.registrationNumber =
                            registrationController.text;
                        context.read<VehicleBloc>().add(UpdateVehicle(vehicle));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vehicle updated successfully'),
                          ),
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
          },
        ),
      ],
    );
  }
}

Future<void> _handleDeleteVehicle(BuildContext context, vehicle) {
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
            onPressed: () {
              context.read<VehicleBloc>().add(DeleteVehicle(vehicle.id));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vehicle and tickets deleted successfully'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
