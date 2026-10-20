import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kTokenKey = "token";

class SecuredAuthStorage {
  final FlutterSecureStorage _storage;

  SecuredAuthStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  Future<void> writeToken({required String token})async{
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<String> readToken() async{
    return await _storage.read(key: _kTokenKey)?? '';
  }

  Future<void> removeToken() async{
    await _storage.delete(key: _kTokenKey);
  }

  Future<void> clear() async{
    await _storage.deleteAll();
  }
}
