import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService().client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      return response.data;
    } on DioException catch (e) {
       // Check for validation errors
      if (e.response?.statusCode == 422) {
         final errors = e.response?.data['data'];
         // Simple flattening of errors for now
         String errorMessage = '';
         if (errors is Map) {
           errors.forEach((key, value) {
             if (value is List) {
               errorMessage += value.join('\n') + '\n';
             }
           });
         }
         throw errorMessage.isNotEmpty ? errorMessage : 'Validation failed';
      }
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (e) {
      // Ignore errors on logout
    }
  }
}
