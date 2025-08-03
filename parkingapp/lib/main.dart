import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parkingapp/blocs/login/login_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_event.dart';
import 'package:parkingapp/blocs/settings/settings_bloc.dart';
import 'package:parkingapp/blocs/settings/settings_event.dart';
import 'package:parkingapp/blocs/settings/settings_state.dart';
import 'package:parkingapp/blocs/signup/signup_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_event.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/parking_space_repository.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/views/login_view.dart';
import 'package:parkingapp/views/parking_view.dart';
import 'package:parkingapp/views/settings_view.dart';
import 'package:parkingapp/views/signup_view.dart';
import 'package:parkingapp/views/ticket_view.dart';
import 'package:parkingapp/views/vehicle_view.dart';
import 'package:shared/shared.dart' as shared;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'layouts/desktop_layout.dart';
import 'widgets/responsive_layout.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('Europe/Stockholm')); // or your default
  }
}

Future<FlutterLocalNotificationsPlugin> initializeNotifications() async {
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = const AndroidInitializationSettings(
    /* '@mipmap/ic_launcher', */
    '@mipmap/parked_car',
  ); // Your app icon, sync in pubspec.yaml

  var initializationSettingsDarwin = const DarwinInitializationSettings();
  var linuxInitializationSettings = const LinuxInitializationSettings(
    defaultActionName:
        'Open notification', // Action name when notification is clicked
  );
  const WindowsInitializationSettings
  initializationSettingsWindows = WindowsInitializationSettings(
    appName: 'parkingapp', // Your app name, sync msix installer in pubspec
    appUserModelId:
        'Com.Example.App', // app name, sync msix intaller in pubspec
    guid:
        'beb011a2-0147-4f9d-9967-e2eef573d39e', // Unique GUID for your app, sync msix installer in pubspec
  );
  // TODO: Generate your own: https://www.guidgenerator.com/ and sync in msix installer in pubspec
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: linuxInitializationSettings,
    windows: initializationSettingsWindows,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}

late final FlutterLocalNotificationsPlugin notificationsPlugin;

Future<void> cleanupAllNotifications() async {
  try {
    // Cancel all notifications
    await notificationsPlugin.cancelAll();
    print('Cleaned up all notifications');
  } catch (e) {
    print('Error cleaning notifications: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationsPlugin = await initializeNotifications();
  await cleanupAllNotifications(); // Clear any lingering notifications

  await _configureLocalTimeZone();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    // Set minimum window size for web
    setWindowMinSize(const Size(850, 900));
    setWindowMaxSize(Size.infinite);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Set minimum window size for desktop
    setWindowMinSize(const Size(850, 600));
    setWindowMaxSize(Size.infinite);
  }

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission(); // Changed from requestPermission

  final channel = AndroidNotificationChannel(
    'parking_reminder_channel',
    'Parking Reminders',
    description: 'Notifications for parking session end times',
    importance: Importance.max,
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  final testChannel = AndroidNotificationChannel(
    'emulator_test_channel',
    'Emulator Tests',
    description: 'For testing notifications on emulator',
    importance: Importance.max,
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(testChannel);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => VehicleBloc(
                vehicleRepository: VehicleRepository(),
                parkingRepository: ParkingRepository(),
              ),
        ),
        BlocProvider(
          create:
              (context) => ParkingBloc(
                parkingRepository: ParkingRepository(),
                parkingSpaceRepository: ParkingSpaceRepository(),
              ),
        ),
        BlocProvider(
          create:
              (context) => TicketBloc(parkingRepository: ParkingRepository()),
        ),
        BlocProvider(
          create: (context) => SignupBloc(personRepository: PersonRepository()),
        ),
        BlocProvider(
          create: (context) => LoginBloc(personRepository: PersonRepository()),
        ),
        BlocProvider(create: (context) => SettingsBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) => previous.themeMode != current.themeMode,
      listener: (context, state) {
        SystemChrome.setSystemUIOverlayStyle(
          state.themeMode == ThemeMode.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        );
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            color: const Color.fromARGB(255, 230, 216, 216),
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
                foregroundColor: Colors.black,
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
            themeMode: state.themeMode,
            home: MyHomePage(title: 'Parking App'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 3;
  late double _currentChildSize;
  bool _isExpanded = true;
  late List<Widget> views;
  late final StreamSubscription<User?> _authSubscription;

  final List<double> _minChildSizes = [0.1, 0.1, 0.1, 1.0];
  final List<double> _initialChildSizes = [0.4, 0.4, 0.4, 1.0];
  final List<double> _maxChildSizes = [0.6, 0.6, 0.6, 1.0];

  bool _showSignup = false;

  @override
  void initState() {
    super.initState();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    _currentIndex = firebaseUser != null ? 0 : 3;
    _currentChildSize = _initialChildSizes[_currentIndex];
    views = [
      const ParkingView(),
      const TicketView(),
      VehicleView(),
      // index 3 will be handled separately
    ];

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user != null) {
        context.read<VehicleBloc>().add(LoadVehicles());
        context.read<ParkingBloc>().add(LoadParkingSpaces());
        context.read<TicketBloc>().add(LoadTickets());
        setState(() {
          _currentIndex = 0;
          _currentChildSize = _initialChildSizes[0];
        });
      } else {
        context.read<VehicleBloc>().add(ResetVehicles());
        context.read<ParkingBloc>().add(ResetParkingEvent());
        context.read<TicketBloc>().add(ResetTickets());
        setState(() {
          _currentIndex = 3;
          _currentChildSize = _initialChildSizes[3];
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) => previous.isLoggedOut != current.isLoggedOut,
      listener: (context, state) {
        if (state.isLoggedOut) {
          setState(() {
            _currentIndex = 3;
            _currentChildSize = _initialChildSizes[3];
          });
          context.read<SettingsBloc>().add(ToggleThemeEvent(false));
          context.read<SettingsBloc>().add(ResetLogoutEvent());
          context.read<VehicleBloc>().add(ResetVehicles());
          context.read<ParkingBloc>().add(ResetParkingEvent());
        }
      },
      child: _buildMainContent(context),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final isDark = context.select<SettingsBloc, bool>(
      (bloc) => bloc.state.themeMode == ThemeMode.dark,
    );

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
          tileBuilder: isDark ? darkModeTileBuilder : null,
          userAgentPackageName: 'com.parkingapp.flutter',
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

    final firebaseUser = FirebaseAuth.instance.currentUser;

    final contentWidget =
        _currentIndex == 3
            ? (firebaseUser != null
                ? const SettingsPage()
                : (_showSignup
                    ? SignupView(
                      onSignup: () {
                        setState(() {
                          _showSignup = false;
                          _currentIndex = 3;
                          _currentChildSize = _initialChildSizes[3];
                        });
                      },
                    )
                    : LoginView(
                      onLogin: () {}, // handle login success in auth listener
                      onSignup: () {
                        setState(() {
                          _showSignup = true;
                        });
                      },
                    )))
            : views[_currentIndex];

    return ResponsiveLayout(
      mobile: Scaffold(
        backgroundColor: const Color.fromARGB(255, 230, 216, 216),
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
            (_currentIndex == 2 && firebaseUser != null)
                ? FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final uuid = Uuid();
                        String registrationNumber = '';
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
                                final credential =
                                    FirebaseAuth.instance.currentUser;
                                if (credential != null) {
                                  final personRepository = PersonRepository();
                                  final person = await personRepository.getById(
                                    credential.uid,
                                  );
                                  shared.Vehicle vehicle = shared.Vehicle(
                                    uuid.v4(),
                                    registrationNumber,
                                    shared.Person(
                                      id: person!.id,
                                      name: person.name,
                                      personId: person.personId,
                                    ),
                                  );
                                  context.read<VehicleBloc>().add(
                                    AddVehicle(vehicle),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vehicle added successfully!',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
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
              // Clamp value to allowed range
              if (_currentChildSize > _maxChildSizes[_currentIndex]) {
                _currentChildSize = _maxChildSizes[_currentIndex];
              }
              if (_currentChildSize < _minChildSizes[_currentIndex]) {
                _currentChildSize = _minChildSizes[_currentIndex];
              }
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
                firebaseUser != null
                    ? Icons.settings
                    : Icons.account_box_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              label: firebaseUser != null ? 'Settings' : 'Login',
            ),
          ],
        ),
      ),
      desktop: DesktopLayout(
        map: mapWidget,
        content: contentWidget,
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
