part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, error }

class LoginState extends Equatable {
  final LoginStatus status;
  final String message;
  final UserModel userModel;

  const LoginState({
    required this.status,
    required this.message,
    required this.userModel,
  });

  factory LoginState.initial() {
    return LoginState(
      status: LoginStatus.initial,
      userModel: UserModel(id: '', name: '', email: ''),
      message: ''
    );
  }

  LoginState copyWith({LoginStatus? status,String? message,UserModel? userModel}){
    return LoginState(status: status??this.status, userModel: userModel??this.userModel,message: message??'');
  }

  @override
  List<Object?> get props => [status, message, userModel];
}
