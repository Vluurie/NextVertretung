import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';

class UserRepository {
  final FlutterSecureStorage _storage;
  late final ApiService apiService;

  UserRepository() : _storage = const FlutterSecureStorage() {
    apiService = ApiService(storage: _storage);
  }

  Future<void> saveCredentials(
      {required String username, required String password}) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  Future<Map<String, String>> getCredentials() async {
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');
    return username != null && password != null
        ? {'username': username, 'password': password}
        : {};
  }

  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }

  Future<bool> hasCredentials() async {
    String? username = await _storage.read(key: 'username');
    String? password = await _storage.read(key: 'password');
    return username != null && password != null;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await apiService.availablePlans(username, password);
      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }
}
