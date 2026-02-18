/// A registered user.
class User {
  User({
    required this.id,
    required this.email,
    required this.password,
    this.dateOfBirth,
  });

  final String id;
  final String email;
  final String password;
  final DateTime? dateOfBirth;
}
