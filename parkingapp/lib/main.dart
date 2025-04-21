import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/views/account_view.dart';
import 'package:parkingapp/views/parking_view.dart';
import 'package:parkingapp/views/signup_view.dart';
import 'package:parkingapp/views/ticket_view.dart';
import 'package:parkingapp/views/vehicle_view.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;
  double _currentChildSize= 0.3;
  bool _isExpanded = false;

  final List<Widget> views = [
    const ParkingView(),
    const TicketView(),
    const VehicleView(),
    const SignupView(),
  ];
  final List<double> _minChildSizes = [0.1, 1.0, 1.0, 1.0];
  final List<double> _initialChildSizes = [0.3, 1.0, 1.0, 1.0];
  final List<double> _maxChildSizes = [0.5, 1.0, 1.0, 1.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                onTap: (_, __) {
                  setState(() {
                    _currentChildSize = _minChildSizes[_currentIndex];
                    _isExpanded = false;
                  });
                },
                initialCenter: LatLng(59.207, 17.901),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      textStyle: const TextStyle(color: Colors.black),
                      onTap:
                          () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            DraggableScrollableSheet(
                key: UniqueKey(),
                initialChildSize: _currentChildSize,
                minChildSize: _minChildSizes[_currentIndex],
                maxChildSize: _maxChildSizes[_currentIndex],
                builder: (context, scrollController) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentChildSize = _isExpanded
                            ? _minChildSizes[_currentIndex]
                            : _maxChildSizes[_currentIndex];
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      alignment: Alignment.bottomLeft,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 230, 216, 216),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: views[_currentIndex],
                        ),
                      ),
                    ),
                  );
                },
              ),
            
          ],
        ),
      ),
      floatingActionButton:
          _currentIndex == 2
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
              )
              : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
            _currentChildSize = _initialChildSizes[newIndex];
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: Colors.black,
              semanticLabel: 'Hitta',
            ),
            label: 'Parking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ad_units_sharp, color: Colors.black),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.directions_car_filled_outlined,
              color: Colors.black,
            ),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined, color: Colors.black),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
