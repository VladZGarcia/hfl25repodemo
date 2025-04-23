class Person {
  final String id;
  String name;
  String? email;
  String? password;
  int? personId;

  Person(
    {required this.id, 
    required this.name,
    this.email,
    this.password,
    this.personId});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      personId: json['personId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'personId': personId,
    };
  }
}
