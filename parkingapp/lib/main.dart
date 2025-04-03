import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkingapp/views/account_view.dart';
import 'package:parkingapp/views/parking_view.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> _index = ValueNotifier<int>(0);
    final views = [const ParkingView(), const AccountView()];

    return ValueListenableBuilder<int>(
      valueListenable: _index,
      builder: (context, value, _) {
        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
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
              DraggableScrollableSheet(
                // Use DraggableScrollableSheet
                initialChildSize: 0.1, // Initial height (adjust as needed)
                minChildSize: 0.1, // Minimum height
                maxChildSize: 0.7, // Maximum height
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 230, 216, 216),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      // For scrollable content
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: views[value],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: value,
            onTap: (newIndex) {
              _index.value = newIndex;
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.car_repair),
                label: 'Parking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_box_outlined),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}
