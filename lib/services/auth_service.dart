import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> signup(String username, String email, String password, String role) async {
    final response = await _apiService.post('/auth/signup', {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
    if (response['token'] != null) {
      await _storage.write(key: 'token', value: response['token']);
      await _storage.write(key: 'user', value: response['result'].toString()); // Simplified for now
      await _storage.write(key: 'role', value: response['result']['role']);
    }
    return response;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (response['token'] != null) {
      await _storage.write(key: 'token', value: response['token']);
      await _storage.write(key: 'user', value: response['result'].toString());
      await _storage.write(key: 'role', value: response['result']['role']);
    }
    return response;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

    Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }
}
