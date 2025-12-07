import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      print('Error inicializando SharedPreferences: $e');
    }
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      print('Error leyendo bool $key: $e');
      return defaultValue;
    }
  }

  static Future<void> setBool(String key, bool value) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('Error escribiendo bool $key: $e');
    }
  }

  static Future<String?> getString(String key) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('Error leyendo string $key: $e');
      return null;
    }
  }

  static Future<void> setString(String key, String value) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      print('Error escribiendo string $key: $e');
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error limpiando preferencias: $e');
    }
  }
}
