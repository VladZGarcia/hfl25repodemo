import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

void configureDesktopWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Parking App');
    setWindowMinSize(const Size(1200, 800));
    setWindowMaxSize(Size.infinite);
    getCurrentScreen().then((screen) {
      if (screen != null) {
        setWindowFrame(
          Rect.fromCenter(
            center: screen.frame.center,
            width: 1400,
            height: 900,
          ),
        );
      }
    });
  }
}
