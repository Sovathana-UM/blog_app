import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    debugPrint('AuthRepository: Attempting to login with email: $email');
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      debugPrint('AuthRepository: Login successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthRepository: Login DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('AuthRepository: Login error response: ${e.response?.data}');
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthRepository: Login unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    debugPrint('AuthRepository: Attempting to register email: $email');
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      debugPrint('AuthRepository: Registration successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthRepository: Register DioException: ${e.message}');
      if (e.response != null) {
        debugPrint(
          'AuthRepository: Register error response: ${e.response?.data}',
        );
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthRepository: Register unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> logout() async {
    debugPrint('AuthRepository: Attempting to logout...');
    try {
      final response = await _dio.post('/logout');
      debugPrint('AuthRepository: Logout successful.');
      return response.data;
    } on DioException catch (e) {
      debugPrint('AuthRepository: Logout DioException: ${e.message}');
      if (e.response != null) {
        debugPrint(
          'AuthRepository: Logout error response: ${e.response?.data}',
        );
        return e.response!.data;
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('AuthRepository: Logout unknown error: $e');
      throw Exception(e.toString());
    }
  }

  Future<UserModel?> getCurrentUser() async {
    debugPrint('AuthRepository: Fetching current user data...');
    try {
      final response = await _dio.get('/user');
      if (response.data['success'] == true) {
        debugPrint('AuthRepository: Current user fetched successfully.');
        return UserModel.fromJson(response.data['data']);
      }
      debugPrint(
        'AuthRepository: Fetch current user failed (success = false).',
      );
      return null;
    } on DioException catch (e) {
      debugPrint('AuthRepository: Fetch user DioException: ${e.message}');
      // Handled globally if 401
      return null;
    } catch (e) {
      debugPrint('AuthRepository: Fetch user unknown error: $e');
      return null;
    }
  }
}
