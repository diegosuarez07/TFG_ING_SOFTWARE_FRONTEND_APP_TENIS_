class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserInfo? userInfo;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.userInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      userInfo: json['userInfo'] != null 
          ? UserInfo.fromJson(json['userInfo']) 
          : null,
    );
  }
}

class UserInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String userType;
  final String skillLevelGame;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userType,
    required this.skillLevelGame,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? '',
      skillLevelGame: json['skillLevelGame'] ?? '',
    );
  }
}