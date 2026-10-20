import 'package:chatter/core/security/secured_auth_storage.dart';
import 'package:chatter/core/storage_service/storage_service.dart';
import 'package:chatter/constants/keys.dart';

class SessionRepository {
  final StorageService _storageService;
  final SecuredAuthStorage _securedAuthStorage;

  SessionRepository({
    required StorageService storageService,
    required SecuredAuthStorage securedAuthStorage,
  }) : _securedAuthStorage = securedAuthStorage,
       _storageService = storageService;

  Future<void> setLoggedIn(bool value)async{
    await _storageService.setBool(StorageKeys.isLoggedIn, value);
  }

  bool isLoggedIn(){
    bool isLoggedIn = _storageService.getBool(StorageKeys.isLoggedIn);
    return isLoggedIn;
  }
  Future<void> setToken(String token) async{
    await _securedAuthStorage.writeToken(token: token);
  }
  Future<String> getToken() async {
    return await _securedAuthStorage.readToken();
  }

  Future<void> removeToken()async{
    await _securedAuthStorage.removeToken();

  }
  Future<void> clearLocalStorage()async{
    await _securedAuthStorage.clear();
    await _storageService.clear();
  }
}
