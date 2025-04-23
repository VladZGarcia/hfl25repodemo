import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  final VoidCallback onLogout;

  SettingsPage({
    super.key,
    required this.themeNotifier,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        height: MediaQuery.of(context).size.height - 50,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                const SizedBox(height: 60.0),
                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  "Under construction",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: const Text(
                'Theme',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeNotifier.value == ThemeMode.dark,
              onChanged: (bool value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
            Container(
              padding: const EdgeInsets.only(top: 3, left: 3),
              child: ElevatedButton(
                onPressed: () {
                  onLogout();
                },
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(
                    side: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
