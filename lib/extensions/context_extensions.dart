import 'package:chatter/modules/user/cubits/user_cubit.dart';
import 'package:chatter/modules/user/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BuildContextUserExt on BuildContext {
  UserModel get watchCurrentUser {
    final userState = watch<UserCubit>().state;
    return userState.userModel;
  }

  UserModel get getCurrentUser {
    final userState = read<UserCubit>().state;
    return userState.userModel;
  }
}
