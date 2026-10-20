import 'package:chatter/constants/keys.dart';
import 'package:chatter/core/network/dio_client.dart';
import 'package:chatter/core/security/secured_auth_storage.dart';
import 'package:chatter/core/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final StorageService storageService;
  final SecuredAuthStorage authStorage;
  final DioClient dioClient;

  AppCubit({
    required this.storageService,
    required this.authStorage,
    required this.dioClient,
  }) : super(AppState.initial());

  void init() async {
    bool isAuthenticated = storageService.getBool(StorageKeys.isLoggedIn);
    String token = await authStorage.readToken();
    dioClient.setToken(token);
    Future.delayed(Duration(seconds: 3), () {
      emit(
        state.copyWith(
          authStatus: isAuthenticated
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
        ),
      );
    });
  }
}
