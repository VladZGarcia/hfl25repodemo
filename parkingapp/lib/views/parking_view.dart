import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_event.dart';
import 'package:parkingapp/blocs/parking/parking_state.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_state.dart';
import 'package:parkingapp/utils/parking_utils.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParkingBloc, ParkingState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }
        return SingleChildScrollView(
          child: Column(
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
                itemCount: state.parkingSpaces.length,
                itemBuilder: (context, index) {
                  final parkingSpace = state.parkingSpaces[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.read<ParkingBloc>().add(
                          SelectParkingSpace(parkingSpace, index),
                        );
                        _handleParking(context, state);
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
                                  state.selectedIndex == index
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
      },
    );
  }

  Future<void> _handleParking(BuildContext context, ParkingState parkingState) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, vehicleState) {
            if (vehicleState is VehicleInitial) {
              context.read<VehicleBloc>().add(LoadVehicles());
              return const Center(child: CircularProgressIndicator());
            }

            if (vehicleState is VehicleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vehicleState is VehicleError) {
              return Center(child: Text('Error: ${vehicleState.message}'));
            }
            return BlocBuilder<ParkingBloc, ParkingState>(
              builder: (context, parkingState) {
                return AlertDialog(
                  title: const Text('Add Parking'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: parkingState.selectedVehicle?.id,
                        hint: const Text('Select a vehicle'),
                        onChanged: (String? newVehicleId) {
                          if (newVehicleId != null &&
                              vehicleState is VehicleLoaded) {
                            final selectedVehicle = vehicleState.vehicles
                                .firstWhere(
                                  (vehicle) => vehicle.id == newVehicleId,
                                );
                            context.read<ParkingBloc>().add(
                              SelectVehicleEvent(selectedVehicle),
                            );
                          }
                        },
                        items:
                            vehicleState is VehicleLoaded
                                ? vehicleState.vehicles.map((vehicle) {
                                  return DropdownMenuItem<String>(
                                    value: vehicle.id,
                                    child: Text(vehicle.registrationNumber),
                                  );
                                }).toList()
                                : [],
                      ),

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? pickedEndTime = await showTimePicker(
                            context: context,
                            initialEntryMode: TimePickerEntryMode.dial,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedEndTime != null) {
                            context.read<ParkingBloc>().add(
                              UpdateParkingTimeEvent(pickedEndTime),
                            );
                          }
                        },
                        child: Text(
                          parkingState.endTime == null
                              ? 'Ongoing parking or Select End Time'
                              : 'End Time: ${parkingState.endTime!.hour.toString().padLeft(2, '0')}:${parkingState.endTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Parking Space: ${parkingState.selectedParkingSpace?.adress}',
                      ),
                      if (parkingState.selectedVehicle?.id != null)
                        Text(
                          'Vehicle: ${parkingState.selectedVehicle?.registrationNumber}',
                        ),
                      if (parkingState.startTime != null)
                        Text(
                          'Start Time: ${parkingState.startTime!.hour.toString().padLeft(2, '0')}:${parkingState.startTime!.minute.toString().padLeft(2, '0')}',
                        ),
                      Text(
                        'Cost per hour: \$${parkingState.selectedParkingSpace?.pricePerHour.toStringAsFixed(2)}',
                      ),
                      Text(
                        parkingState.endTime != null
                            ? 'End Time: ${parkingState.endTime!.hour.toString().padLeft(2, '0')}:${parkingState.endTime!.minute.toString().padLeft(2, '0')}'
                            : 'End Time: Ongoing',
                      ),
                      if (parkingState.cost != null)
                        Text(
                          'Cost: \$${parkingState.cost!.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          (parkingState.selectedVehicle != null &&
                                  parkingState.startTime != null)
                              ? () {
                                context.read<ParkingBloc>().add(
                                  AddParkingEvent(
                                    vehicle: parkingState.selectedVehicle!,
                                    parkingSpace:
                                        parkingState.selectedParkingSpace!,
                                    startTime:
                                        parkingState.startTime!.toDateTime(),
                                    endTime: parkingState.endTime?.toDateTime(),
                                  ),
                                );
                                // Notify TicketBloc to reload tickets
                                context.read<TicketBloc>().add(LoadTickets());
                                Navigator.of(context).pop();
                              }
                              : null,
                      child: const Text('Add'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ParkingBloc>().add(ResetParkingEvent());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
