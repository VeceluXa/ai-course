import 'package:shared_preferences/shared_preferences.dart';

abstract class PrefsStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements PrefsStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _instance();
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _instance();
    await prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance();
    await prefs.remove(key);
  }
}
