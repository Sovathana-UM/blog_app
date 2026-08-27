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
        '/auth/login',
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
        '/auth/register',
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
      final response = await _dio.post('/auth/logout');
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
      final response = await _dio.get('/current-user');
      if (response.data['success'] == true) {
        debugPrint('AuthRepository: Current user fetched successfully.');
        return UserModel.fromJson(response.data['data']);
      }
      debugPrint('AuthRepository: Fetch current user failed (success = false).');
      return null;
    } on DioException catch (e) {
      debugPrint('AuthRepository: Fetch user DioException: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('AuthRepository: Fetch user unknown error: $e');
      return null;
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _dio.post('/current-user/fcm-token', data: {'fcm_token': token});
    } catch (e) {
      debugPrint('AuthRepository: updateFcmToken error: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/current-user', data: data);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'success': false, 'message': 'Unknown error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> changePassword(String current, String newPass, String confirmPass) async {
    try {
      final response = await _dio.put('/current-user/password', data: {
        'current_password': current,
        'new_password': newPass,
        'new_password_confirmation': confirmPass,
      });
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'success': false, 'message': 'Unknown error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String imagePath) async {
    try {
      String fileName = imagePath.split('/').last;
      if (!fileName.contains('.')) fileName = '$fileName.jpg';

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      final response = await _dio.post('/current-user/avatar', data: formData);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'success': false, 'message': 'Unknown error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateFullProfile({
    required String firstName,
    required String lastName,
    required String bio,
    required String location,
    String? avatarPath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'bio': bio,
        'location': location,
      });

      if (avatarPath != null && avatarPath.isNotEmpty) {
        String fileName = avatarPath.split('/').last;
        if (!fileName.contains('.')) fileName = '$fileName.jpg';
        formData.files.add(
          MapEntry('avatar', await MultipartFile.fromFile(avatarPath, filename: fileName)),
        );
      }

      final response = await _dio.post('/current-user', data: formData);
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ?? {'success': false, 'message': 'Unknown error'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
