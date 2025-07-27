import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends SettingsEvent {
  final bool isDark;
  const ToggleThemeEvent(this.isDark);

  @override
  List<Object?> get props => [isDark];
}

class LogoutEvent extends SettingsEvent {}
