 import 'package:flutter/material.dart';

extension TimeConversion on TimeOfDay {
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      this.hour,
      this.minute,
    );
  }
  }