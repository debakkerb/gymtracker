/// A registered user returned from the API.
class User {
  const User({required this.id, required this.email, this.dateOfBirth});

  final String id;
  final String email;
  final DateTime? dateOfBirth;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    dateOfBirth: json['date_of_birth'] == null
        ? null
        : DateTime.tryParse(json['date_of_birth'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String(),
  };
}
