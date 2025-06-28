// lib/models/user.dart
class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String userType;
  final String skillLevelGame;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.userType,
    required this.skillLevelGame,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'userType': userType,
      'skillLevelGame': skillLevelGame,
    };
  }
}