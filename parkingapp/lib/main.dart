import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkingapp/views/account_view.dart';
import 'package:parkingapp/views/parking_view.dart';
import 'package:parkingapp/views/signup_view.dart';
import 'package:parkingapp/views/ticket_view.dart';
import 'package:parkingapp/views/vehicle_view.dart';
import 'package:url_launcher/url_launcher.dart';

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
  double _currentChildSize = 0.4;

  final List<Widget> views = [
    const ParkingView(),
    const TicketView(),
    const VehicleView(),
    const SignupView(),
  ];

  final List<double> _initialChildSizes = [0.1, 0.4, 0.5, 1.0];
  final List<double> _maxChildSizes = [0.5, 0.5, 0.8, 1.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height - kBottomNavigationBarHeight,
        child: Stack(
          children: [
            GestureDetector(
              /*  onTapDown: (_) {
                
                // Handle tap down event to get the position of the tap
                setState(() {
                  _currentChildSize = _initialChildSizes[_currentIndex];
                });
              }, */
              /* onTap: () {
                setState(() {
                  _currentChildSize = _initialChildSizes[_currentIndex];
                  
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Map tapped!'),
                    duration: const Duration(seconds: 1),
                  ));
                });
              }, */
              child: FlutterMap(
                options: MapOptions(
                  onTap: (_, __) {
                    setState(() {
                      _currentChildSize = _initialChildSizes[_currentIndex];
                    });
                  },
                  initialCenter: LatLng(59.207, 17.901),
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            ),
            DraggableScrollableSheet(
              key: UniqueKey(),
              initialChildSize: _currentChildSize,
              minChildSize: _initialChildSizes[_currentIndex],
              maxChildSize: _maxChildSizes[_currentIndex],
              builder: (context, scrollController) {
                return Container(
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
                );
              },
            ),
          ],
        ),
      ),
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
