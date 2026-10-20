import 'package:chatter/modules/user/models/user_model.dart';

AuthResponse authResponseFromJson(dynamic json) => AuthResponse.fromJson(json);

class AuthResponse {
  final UserModel user;
  String? token;

  AuthResponse({required this.user, this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'token': token};
}
