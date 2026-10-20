import 'package:dio/dio.dart';

class SignupInput {
  final String name;
  final String email;
  final String password;

  String? fcmToken;

  SignupInput({required this.name,required this.email,required this.password,this.fcmToken});

  Map<String,dynamic> toJson() =>{
    'name' : name,
    'email' : email,
    'password': password,
    'fcmToken' : fcmToken
  };

  FormData toFromData()=> FormData.fromMap({
    'name' : name,
    'email' : email,
    'password': password,
    'fcmToken' : fcmToken
  });

}