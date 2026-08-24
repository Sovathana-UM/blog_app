import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../../../core/network/dio_client.dart';

class PostRepository {
  final Dio _dio = DioClient().dio;

  Future<List<PostModel>> getPosts({String? userId}) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('PostRepository: Fetch posts DioException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('PostRepository: Fetch posts unknown error: $e');
      throw Exception(e.toString());
    }
  }
}
