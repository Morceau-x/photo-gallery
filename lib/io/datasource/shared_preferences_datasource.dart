import 'package:photo_gallery/io/datasource/storage_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesDatasource implements StorageDatasource {
  final SharedPreferences _prefs;

  SharedPreferencesDatasource(this._prefs);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> read(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> deleteAll() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    final keys = _prefs.getKeys();
    final result = <String, String>{};
    for (final key in keys) {
      final value = _prefs.get(key);
      if (value is String) {
        result[key] = value;
      }
    }
    return result;
  }
}
