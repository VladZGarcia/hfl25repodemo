import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoggedOut;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.isLoggedOut = false,
  });

  SettingsState copyWith({ThemeMode? themeMode, bool? isLoggedOut}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }

  @override
  List<Object?> get props => [themeMode, isLoggedOut];
}
