class UserModel {
  final int userId;
  final String username;
  final String email;
  final String token;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json,
      {required String token}) {
    return UserModel(
      userId: json['user_id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'email': email,
        'token': token,
      };
}
