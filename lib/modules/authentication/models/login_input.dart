import 'package:dio/dio.dart';

class LoginInput {
  final String email;
  final String password;
  String? fcmToken;

  LoginInput({required this.email, required this.password, this.fcmToken});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fcmToken': fcmToken,
  };

  FormData toFromData() => FormData.fromMap({
    'email': email,
    'password': password,
    'fcmToken': fcmToken,
  });
}
