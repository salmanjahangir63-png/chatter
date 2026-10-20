import 'package:chatter/core/exceptions/api_error.dart';
import 'package:chatter/modules/authentication/models/signup_input.dart';
import 'package:chatter/modules/authentication/repository/auth_repository.dart';
import 'package:chatter/modules/user/models/user_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;
  SignUpCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(SignUpState.initial());

  Future<void> signUp(SignupInput signUpInput) async {
    try {

      emit(state.copyWith(status: SignUpStatus.loading));

      UserModel user = await _authRepository.signUp(signUpInput);
      emit(
        state.copyWith(
          userModel: user,
          message: 'SignUp Successful',
          status: SignUpStatus.success,
        ),
      );
    }
    on ApiError catch(e){

      emit(state.copyWith(message: e.message, status: SignUpStatus.error));
    }
    catch (e) {

      emit(state.copyWith(message: e.toString(), status: SignUpStatus.error));
    }
  }
}
