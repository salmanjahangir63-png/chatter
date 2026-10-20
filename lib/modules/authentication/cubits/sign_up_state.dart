part of 'sign_up_cubit.dart';

enum SignUpStatus { initial, loading, success, error }

class SignUpState extends Equatable {
  final SignUpStatus status;
  final String message;
  final UserModel userModel;

  const SignUpState({
    required this.status,
    required this.message,
    required this.userModel,
  });

  factory SignUpState.initial() {
    return SignUpState(
      status: SignUpStatus.initial,
      message: '',
      userModel: UserModel(id: '', name: '', email: ''),
    );
  }

  SignUpState copyWith({
    SignUpStatus? status,
    String? message,
    UserModel? userModel,
  }) {
    return SignUpState(
      status: status ?? this.status,
      message: message ?? '',
      userModel: userModel ?? this.userModel,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, message, userModel];
}
