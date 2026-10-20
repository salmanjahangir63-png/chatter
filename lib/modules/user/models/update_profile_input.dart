import 'package:dio/dio.dart';

class UpdateProfileInput {
  final String name;
  MultipartFile? profileImage;

  UpdateProfileInput({required this.name,this.profileImage});

  FormData toFormData()=> FormData.fromMap({
    'name' : name,
    'profileImage' : profileImage
  });

}