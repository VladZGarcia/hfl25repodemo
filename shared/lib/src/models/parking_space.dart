import 'package:intl/intl.dart';

class Parkingspace {
  final String id;
  String spaceId;
  String adress;
  int pricePerHour;

  Parkingspace(this.id, this.spaceId, this.adress, this.pricePerHour);

  factory Parkingspace.fromJson(Map<String, dynamic> json) {
    return Parkingspace(
      json['id'],
      json['spaceId'],
      json['adress'],
      json['pricePerHour'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spaceId': spaceId,
      'adress': adress,
      'pricePerHour': pricePerHour,
    };
  }
  
  /// Formats a DateTime object to a string in the format HH:MM.
  String formatTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String formatDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
}
