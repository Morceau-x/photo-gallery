import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_gallery/io/datasource/storage_datasource.dart';

class SecureStorageDatasource implements StorageDatasource {
  final FlutterSecureStorage _storage;

  SecureStorageDatasource({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
