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
}
