import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/material.dart';


class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState(themeMode: ThemeMode.light)) {
    on<ToggleThemeEvent>((event, emit) {
      emit(
        state.copyWith(
          themeMode: event.isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      );
    });
    on<LogoutEvent>((event, emit) {
      emit(state.copyWith(isLoggedOut: true));
    });
    on<ResetLogoutEvent>((event, emit) {
      emit(state.copyWith(isLoggedOut: false));
    });
  }
}

