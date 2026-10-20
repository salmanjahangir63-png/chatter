import 'package:chatter/constants/api_endpoints.dart';
import 'package:chatter/core/common/repositories/session_repository.dart';
import 'package:chatter/core/exceptions/api_error.dart';
import 'package:chatter/core/network/api_results.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/modules/authentication/models/auth_response.dart';
import 'package:chatter/modules/authentication/models/login_input.dart';
import 'package:chatter/modules/authentication/models/signup_input.dart';
import 'package:chatter/modules/user/models/user_model.dart';
import 'package:chatter/modules/user/repository/user_account_repository.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SessionRepository _sessionRepository;
  final UserAccountRepository _userAccountRepository;

  AuthRepository({
    required DioClient dioClient,
    required SessionRepository sessionRepository,
    required UserAccountRepository userAccountRepository,
  }) : _dioClient = dioClient,
       _sessionRepository = sessionRepository,
       _userAccountRepository = userAccountRepository;

  Future<UserModel> logIn(LoginInput logInInput) async {
    try {
      var response = await _dioClient.post(
        ApiEndpoints.login,
        data: logInInput.toJson(),
      );
      AuthResponse authResponse = AuthResponse.fromJson(response.data);
      UserModel userModel = authResponse.user;
      await _userAccountRepository.saveUserInDb(userModel);
      await _sessionRepository.setToken(authResponse.token!);
      _dioClient.setToken(authResponse.token!);
      await _sessionRepository.setLoggedIn(true);
      return userModel;
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } on TypeError catch (e) {
      throw ApiError(message: e.toString(), code: 0);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<UserModel> signUp(SignupInput signUpInput) async {
    try {
      var response = await _dioClient.post(
        ApiEndpoints.signup,
        data: signUpInput.toFromData(),
      );
      if (response.data['result'] == ApiResult.success) {
        AuthResponse authResponse = AuthResponse.fromJson(response.data);
        UserModel userModel = authResponse.user;
        await _userAccountRepository.saveUserInDb(userModel);
        await _sessionRepository.setToken(authResponse.token!);
        _dioClient.setToken(authResponse.token!);
        await _sessionRepository.setLoggedIn(true);
        return userModel;
      }
      throw response.data['message'];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    } on TypeError catch (e) {
      throw ApiError(message: e.toString());
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
}
