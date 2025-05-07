import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/views/account_view.dart';
import 'package:parkingapp/views/parking_view.dart';
import 'package:parkingapp/views/settings_view.dart';
import 'package:parkingapp/views/signup_view.dart';
import 'package:parkingapp/views/ticket_view.dart';
import 'package:parkingapp/views/vehicle_view.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'layouts/desktop_layout.dart';
import 'widgets/responsive_layout.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Set minimum window size for web
    setWindowMinSize(const Size(850, 900));
    setWindowMaxSize(Size.infinite);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Set minimum window size for desktop
    setWindowMinSize(const Size(850, 600));
    setWindowMaxSize(Size.infinite);
  }
  /* BlockProvider(create: (context) => AuthBlock(authRepository), child: MyApp()); */
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        SystemChrome.setSystemUIOverlayStyle(
          themeNotifier.value == ThemeMode.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        );
        return MaterialApp(
          color: Color.fromARGB(255, 230, 216, 216),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.purple,
              surface: const Color(0xFFE6D8D8),
              onSurface: Colors.grey[900]!,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFE6D8D8),
              foregroundColor: Colors.black, // Text color for AppBar
            ),
            scaffoldBackgroundColor: const Color(0xFFE6D8D8),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          themeMode: currentMode,
          home: MyHomePage(themeNotifier: themeNotifier, title: 'Parking App'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MyHomePage({
    super.key,
    required this.title,
    required this.themeNotifier,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 3;
  late double _currentChildSize;
  bool _isExpanded = true;
  bool _isLoggedIn = false;
  bool _isSignedIn = false;
  late List<Widget> views;

  void _toggleLoginState() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
    });
  }

  void _toggleSignupState() {
    setState(() {
      _isSignedIn = !_isSignedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentChildSize = _initialChildSizes[_currentIndex];
    views = [
      const ParkingView(),
      const TicketView(),
      const VehicleView(),
      AccountView(onLogin: _toggleLoginState, onSignup: _toggleSignupState),
    ];
  }

  final List<double> _minChildSizes = [0.1, 0.1, 0.1, 1.0];
  final List<double> _initialChildSizes = [0.4, 0.4, 0.5, 1.0];
  final List<double> _maxChildSizes = [0.5, 0.5, 0.6, 1.0];

  @override
  Widget build(BuildContext context) {
    final mapWidget = FlutterMap(
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
          tileProvider: CancellableNetworkTileProvider(),
          tileBuilder:
              widget.themeNotifier.value == ThemeMode.dark
                  ? darkModeTileBuilder
                  : null,
          userAgentPackageName: 'com.example.app',
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              '© OpenStreetMap contributors',
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onTap:
                  () => launchUrl(
                    Uri.parse('https://www.openstreetmap.org/copyright'),
                  ),
            ),
          ],
        ),
      ],
    );

    final contentWidget =
        _currentIndex == 3
            ? (_isLoggedIn
                ? SettingsPage(
                  themeNotifier: widget.themeNotifier,
                  onLogout: _toggleLoginState,
                )
                : (_isSignedIn
                    ? AccountView(
                      onLogin: _toggleLoginState,
                      onSignup: _toggleSignupState,
                    )
                    : SignupView(onSignup: _toggleSignupState)))
            : views[_currentIndex];

    return ResponsiveLayout(
      mobile: Scaffold(
        backgroundColor: Color.fromARGB(255, 230, 216, 216),
        body: Stack(
          children: [
            mapWidget,
            DraggableScrollableSheet(
              key: UniqueKey(),
              initialChildSize: _currentChildSize,
              minChildSize: _minChildSizes[_currentIndex],
              maxChildSize: _maxChildSizes[_currentIndex],
              builder: (context, scrollController) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentChildSize =
                          _isExpanded
                              ? _minChildSizes[_currentIndex]
                              : _maxChildSizes[_currentIndex];
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top:
                            _currentIndex == 3
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: contentWidget,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vehicle added successfully!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                setState(() {
                                  views[2] =
                                      const VehicleView(); // Refresh the VehicleView
                                });
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
          selectedItemColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelStyle: const TextStyle(color: Colors.black),
          selectedLabelStyle: const TextStyle(color: Colors.black),
          showUnselectedLabels: false,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
              _currentChildSize = _initialChildSizes[newIndex];
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
                semanticLabel: 'Hitta',
              ),
              label: 'Parking',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.ad_units_sharp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.directions_car_filled_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: 'Vehicles',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_box_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
      desktop: DesktopLayout(
        map: mapWidget,
        content: contentWidget,
        themeNotifier: widget.themeNotifier,
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
            _currentChildSize = _initialChildSizes[index];
          });
        },
      ),
    );
  }
}
