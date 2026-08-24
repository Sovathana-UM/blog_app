import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'dio_client.dart';

class AuthProvider {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    debugPrint('AuthProvider: Attempting to login with email: $email');
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      debugPrint('AuthProvider: Login successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthProvider: Login DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('AuthProvider: Login error response: ${e.response?.data}');
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthProvider: Login unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> register(String firstName, String lastName, String email, String password, String passwordConfirmation) async {
    debugPrint('AuthProvider: Attempting to register email: $email');
    try {
      final response = await _dio.post('/register', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      debugPrint('AuthProvider: Registration successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthProvider: Register DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('AuthProvider: Register error response: ${e.response?.data}');
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthProvider: Register unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> logout() async {
    debugPrint('AuthProvider: Attempting to logout...');
    try {
      final response = await _dio.post('/logout');
      debugPrint('AuthProvider: Logout successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthProvider: Logout DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('AuthProvider: Logout error response: ${e.response?.data}');
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthProvider: Logout unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    debugPrint('AuthProvider: Fetching current user data...');
    try {
      final response = await _dio.get('/user');
      if (response.data['success'] == true) {
        debugPrint('AuthProvider: Current user fetched successfully.');
        return UserModel.fromJson(response.data['data']);
      }
      debugPrint('AuthProvider: Fetch current user failed (success = false).');
      return null;
    } on DioException catch (e) {
      debugPrint('AuthProvider: Fetch user DioException: ${e.message}');
      // Handled globally if 401
      return null;
    } catch (e) {
      debugPrint('AuthProvider: Fetch user unknown error: $e');
      return null;
    }
  }
}
