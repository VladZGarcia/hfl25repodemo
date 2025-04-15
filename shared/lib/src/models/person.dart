class Person {
  final String id;
  String name;
  // String address;
  String? email;
  // String phone;
  int? personId;

  Person(
    {required this.id, 
    required this.name, 
    // this.address, 
    this.email, 
    // this.phone, 
    this.personId});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      // address: json['address'],
      email: json['email'],
      // phone: json['phone'],
      personId: json['personId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'address': address,
      'email': email,
      // 'phone': phone,
      'personId': personId,
    };
  }
}
