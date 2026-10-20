part of 'app_cubit.dart';

enum AuthStatus { authenticated, unauthenticated }

class AppState {
  final AuthStatus authStatus;
  AppState({required this.authStatus});

  factory AppState.initial() {
    return AppState(authStatus: AuthStatus.unauthenticated);
  }
  AppState copyWith({AuthStatus? authStatus}) {
    return AppState(authStatus: authStatus ?? this.authStatus);
  }
}
