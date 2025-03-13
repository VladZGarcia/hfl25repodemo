class Person {
  final String id;
  String name;
  /* String address;
  String email;
  String phone; */
  int personId;

  Person(this.id, this.name, /* this.address, this.email, this.phone, */ this.personId);

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      json['id'],
      json['name'],
      /* json['address'],
      json['email'],
      json['phone'], */
      json['personId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      /* 'address': address,
      'email': email,
      'phone': phone, */
      'personId': personId,
    };
  }
}
