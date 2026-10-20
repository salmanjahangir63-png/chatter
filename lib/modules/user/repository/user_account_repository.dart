import 'dart:convert';

import 'package:chatter/constants/api_endpoints.dart';
import 'package:chatter/constants/keys.dart';
import 'package:chatter/core/common/repositories/session_repository.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/modules/user/models/update_profile_input.dart';
import 'package:dio/dio.dart';

import '../../../core/exceptions/api_error.dart';
import '../../../core/storage_service/storage_service.dart';
import '../../user/models/user_model.dart';

class UserAccountRepository {
  StorageService storageService;
  SessionRepository sessionRepository;
  DioClient dioClient;

  UserAccountRepository({
    required this.storageService,
    required this.sessionRepository,
    required this.dioClient,
  });

  Future<void> saveUserInDb(UserModel userModel) async {
    final userMap = userModel.toJson();
    await storageService.setString(StorageKeys.user, json.encode(userMap));
  }

  UserModel getUserFromDb() {
    final userString = storageService.getString(StorageKeys.user);
    if (userString.isNotEmpty) {
      final Map<String, dynamic> userMap = jsonDecode(userString);
      UserModel userModel = UserModel.fromJson(userMap);
      return userModel;
    } else {
      return UserModel.empty;
    }
  }

  Future<UserModel> updateProfile(UpdateProfileInput input) async {
    try {
      var response = await dioClient.patch(
        ApiEndpoints.update,
        data: input.toFormData(),
      );

      if (response.data['result'] == 'success') {
        UserModel userModel = UserModel.fromJson(response.data['data']);
        await saveUserInDb(userModel);
        return userModel;
      }
      throw ApiError.fromDioException(response.data['message']);
    } on DioException catch (e, stackTrace) {
      throw ApiError.fromDioException(e);
    } catch (e) {
      throw ApiError(message: '$e', code: 0);
    }
  }

  Future<void> removeUserFromDb() async {
    await storageService.remove(StorageKeys.user);
  }

  Future<void> logout() async {
    await sessionRepository.setLoggedIn(false);
    await sessionRepository.removeToken();
    await sessionRepository.clearLocalStorage();
    await removeUserFromDb();
  }
}
