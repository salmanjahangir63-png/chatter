part of 'user_cubit.dart';

enum UserStatus {
  initial,
  loading,
  loggingOut,
  loggedOut,
  updating,
  updated,
  success,
  error,
}

class UserState extends Equatable {
  final UserStatus status;
  final UserModel userModel;
  final String errorMessage;

  const UserState({
    required this.status,
    required this.userModel,
    required this.errorMessage,
  });

  factory UserState.initial() {
    return UserState(
      status: UserStatus.initial,
      userModel: UserModel.empty,
      errorMessage: '',
    );
  }

  UserState copyWith({
    UserStatus? status,
    UserModel? userModel,
    String? errorMessage,
  }) {
    return UserState(
      userModel: userModel ?? this.userModel,
      status: status?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [userModel, status];
}