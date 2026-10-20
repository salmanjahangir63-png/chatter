import 'package:shared_preferences/shared_preferences.dart';
class StorageService {
  final SharedPreferences _sharedPreferences;

  StorageService({required SharedPreferences sharedPreferences}):_sharedPreferences = sharedPreferences;

  Future<void> setString(String key,String value)async{
    await _sharedPreferences.setString(key, value);
  }
  Future<void> setInt(String key,int value)async{
    await _sharedPreferences.setInt(key, value);
  }

  int getInt(String key){
   return _sharedPreferences.getInt(key)??0;
  }

  Future<void> setBool(String key,bool value)async{
    await _sharedPreferences.setBool(key, value);
  }

  bool getBool(String key,[value]){
   return _sharedPreferences.getBool(key)??value??false;
  }

  String getString(String key,[value]){
    return _sharedPreferences.getString(key)??value??'';
  }

  Future<bool> remove(String key)async{
    return await _sharedPreferences.remove(key);
  }

  Future<bool> clear()async{
    return await _sharedPreferences.clear();
  }

}