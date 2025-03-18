import 'package:shared_preferences/shared_preferences.dart';

Future<String> readStringData(String key) async {
  final storage = await SharedPreferences.getInstance();
  return storage.getString(key) ?? "undefined";
}
Future<int> readIntegerData(String key) async {
  final storage = await SharedPreferences.getInstance();
  return storage.getInt(key) ?? -1;
}

Future<bool> writeStringData(String key, String payload) async {
  final storage = await SharedPreferences.getInstance();
  await storage.setString(key, payload);
  return true;
}
Future<bool> writeIntegerData(String key, int payload) async {
  final storage = await SharedPreferences.getInstance();
  await storage.setInt(key, payload);
  return true;
}
Future<bool> writeBooleanData(String key, bool payload) async {
  final storage = await SharedPreferences.getInstance();
  await storage.setBool(key, payload);
  return true;
}

Future<bool> deleteData(String key) async {
  final storage = await SharedPreferences.getInstance();
  await storage.remove(key);
  return true;
}