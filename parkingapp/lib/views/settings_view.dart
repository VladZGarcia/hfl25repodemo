import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen:
          (previous, current) => previous.isLoggedOut != current.isLoggedOut,
      listener: (context, state) {
        if (state.isLoggedOut) {
          // Navigate to login or perform logout logic
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
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
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      context.read<SettingsBloc>().add(ToggleThemeEvent(value));
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 3, left: 3),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SettingsBloc>().add(LogoutEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(
                          side: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
