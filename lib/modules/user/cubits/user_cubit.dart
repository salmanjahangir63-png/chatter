import 'dart:io';

import 'package:chatter/modules/user/models/update_profile_input.dart';
import 'package:chatter/modules/user/models/user_model.dart';
import 'package:chatter/modules/user/repository/user_account_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/exceptions/api_error.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({required UserAccountRepository userAccountRepository})
    : _userAccountRepository = userAccountRepository,
      super(UserState.initial());

  final UserAccountRepository _userAccountRepository;

  void loadUser() {
    UserModel userModel = _userAccountRepository.getUserFromDb();
    emit(state.copyWith(userModel: userModel, status: UserStatus.success));
  }

  Future<void> logout() async {
    emit(state.copyWith(status: UserStatus.loggingOut));
    await Future.delayed(const Duration(seconds: 2));
    await _userAccountRepository.logout();
    emit(
      state.copyWith(status: UserStatus.loggedOut, userModel: UserModel.empty),
    );
  }

  void updateProfile(UpdateProfileInput input, File? file) async {
    emit(state.copyWith(status: UserStatus.updating));
    try {
      UserModel userModel = await _userAccountRepository.updateProfile(input);
      emit(state.copyWith(status: UserStatus.updated, userModel: userModel));
    } on ApiError catch (e) {
      emit(state.copyWith(status: UserStatus.error, errorMessage: e.message));
    } catch (_) {}
  }
}
