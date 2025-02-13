import 'package:intl/intl.dart';

bool isValid<T>(T? value) {
  if (value == null) {
    return false;
  }
  if (value is String) {
    return value.isNotEmpty;
  } else if (value is Iterable) {
    return value.isNotEmpty;
  } else if (value is Map) {
    return value.isNotEmpty;
  }
  return true;
}

extension FindStuff<T> on List<T> {
  T? goodFirstWhere(bool Function(T item) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}

double calculatePrice(DateTime startTime, DateTime endTime, double pricePerHour) {
  Duration duration = endTime.difference(startTime);
  double hours = duration.inMinutes / 60;
  double totalcost = hours * pricePerHour;
  return totalcost;
}


