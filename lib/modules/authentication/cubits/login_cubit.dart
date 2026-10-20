import 'package:chatter/core/di/service_locator.dart';
import 'package:chatter/core/exceptions/api_error.dart';
import 'package:chatter/core/notifications/cloud_messaging_api.dart';
import 'package:chatter/modules/authentication/models/login_input.dart';
import 'package:chatter/modules/authentication/repository/auth_repository.dart';
import 'package:chatter/modules/user/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  LoginCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(LoginState.initial());

  Future<void> logIn(LoginInput logInInput) async {
    try {

      emit(state.copyWith(status: LoginStatus.loading));

      final fcm = sl<CloudMessagingApi>();
      String? fcmToken = await fcm.getFcmToken();
      logInInput.fcmToken = fcmToken;
      UserModel user = await _authRepository.logIn(logInInput);
      emit(
        state.copyWith(
          userModel: user,
          message: 'Login Successful',
          status: LoginStatus.success,
        ),
      );
    }
    on ApiError catch(e){

      emit(state.copyWith(message: e.message, status: LoginStatus.error));
    }
    catch (e) {

      emit(state.copyWith(message: e.toString(), status: LoginStatus.error));
    }
  }
}
