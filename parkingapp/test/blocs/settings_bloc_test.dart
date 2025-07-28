import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkingapp/blocs/settings/settings_bloc.dart';
import 'package:parkingapp/blocs/settings/settings_event.dart';
import 'package:parkingapp/blocs/settings/settings_state.dart';

void main() {
  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits [ThemeMode.dark] when ToggleThemeEvent(isDark: true) is added',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const ToggleThemeEvent(true)),
      expect:
          () => [
            const SettingsState(themeMode: ThemeMode.dark, isLoggedOut: false),
          ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [ThemeMode.light] when ToggleThemeEvent(isDark: false) is added',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(const ToggleThemeEvent(false)),
      expect:
          () => [
            const SettingsState(themeMode: ThemeMode.light, isLoggedOut: false),
          ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [isLoggedOut: true] when LogoutEvent is added',
      build: () => SettingsBloc(),
      act: (bloc) => bloc.add(LogoutEvent()),
      expect:
          () => [
            const SettingsState(themeMode: ThemeMode.light, isLoggedOut: true),
          ],
    );
  });
}
