import 'package:flutter/material.dart';

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
                                  constraints.maxHeight -
                                  32, // Account for padding
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
