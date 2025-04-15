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
  late Vehicle _selectedVehicle;
  late Parkingspace _selectedParkingSpace;
  String? _selectedParkingSpaceAddress;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double? _cost;
  final Uuid uuid = const Uuid();

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
                          _selectedParkingSpace = parkingSpace;
                          _selectedParkingSpaceAddress = parkingSpace.adress;
                          _startTime =
                              TimeOfDay.now(); // Set start time to current time
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
            child: Text('Error loading parking spaces: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _handleParking(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Parking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: VehicleRepository().getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading vehicles: ${snapshot.error}',
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No vehicles available.'),
                        );
                      } else {
                        return DropdownButton<String>(
                          value: _selectedVehicleId,
                          hint: const Text('Select a vehicle'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVehicleId = newValue;
                              _selectedVehicle = snapshot.data!.firstWhere(
                                (vehicle) => vehicle.id == newValue,
                              );
                            });
                          },
                          items:
                              snapshot.data!.map<DropdownMenuItem<String>>((
                                vehicle,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: vehicle.id,
                                  child: Text(vehicle.registrationNumber),
                                );
                              }).toList(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? pickedEndTime = await showTimePicker(
                        context: context,
                        initialEntryMode: TimePickerEntryMode.input,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedEndTime != null) {
                        setState(() {
                          _endTime = pickedEndTime;
                          var price = _selectedParkingSpace.pricePerHour;
                          _calculateCost(price);
                        });
                      }
                    },
                    child: Text(
                      _endTime == null
                          ? 'Select End Time'
                          : 'End Time: ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedParkingSpaceAddress != null)
                    Text('Parking Space: $_selectedParkingSpaceAddress'),
                  if (_selectedVehicleId != null)
                    Text('Vehicle: ${_selectedVehicle.registrationNumber}'),
                  if (_startTime != null) Text('Start Time: $_startTime'),
                  Text(
                    'Cost per hour: \$${_selectedParkingSpace.pricePerHour.toStringAsFixed(2)}',
                  ),
                    Text(
                      _endTime != null
                          ? 'End Time: ${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                          : 'End Time: Ongoing',
                    ),
                  if (_cost != null)
                    Text('Cost: \$${_cost!.toStringAsFixed(2)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      (_selectedVehicleId != null && _startTime != null)
                          ? () async {
                            var newParking = Parking(
                              uuid.v4(),
                              _selectedVehicle,
                              _selectedParkingSpace,
                              _convertTimeOfDayToDateTime(_startTime!),
                              _endTime != null
                                  ? _convertTimeOfDayToDateTime(_endTime!)
                                  : null,
                            );
                            await (ParkingRepository().addParking(newParking));
                            // Close the dialog and clear selections
                            _clearSelections();
                            Navigator.of(context).pop();
                          }
                          : null,
                  child: const Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    // Close the dialog and clear selections
                    _clearSelections();
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

  void _clearSelections() {
    setState(() {
      _selectedVehicleId = null;
      _selectedParkingSpaceAddress = null;
      _startTime = null;
      _endTime = null;
      _cost = null;
    });
  }

  void _calculateCost(price) {
    if (_startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;
      var costPerMinute = (price / 60); // Example cost per minute
      _cost = (durationMinutes * costPerMinute).toDouble();
    }
  }
}
