import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../models/category_model.dart';
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

  Future<List<PostModel>> getMyPosts() async {
    try {
      final response = await _dio.get('/my-posts');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('PostRepository getMyPosts error: $e');
      return [];
    }
  }

  Future<List<PostModel>> getSavedPosts() async {
    try {
      final response = await _dio.get('/saved-posts');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('PostRepository getSavedPosts error: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('PostRepository getCategories error: $e');
      return [];
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/like');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> savePost(String postId) async {
    try {
      final response = await _dio.post('/posts/$postId/save');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
    int? categoryId,
    required String imagePath,
  }) async {
    try {
      String fileName = imagePath.split('/').last;
      if (!fileName.contains('.')) {
        fileName = '$fileName.jpg';
      }

      final formData = FormData.fromMap({
        if (title.isNotEmpty) 'title': title,
        if (content.isNotEmpty) 'content': content,
        if (categoryId != null) 'category_id': categoryId,
        'image': await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      final response = await _dio.post('/posts', data: formData);

      return response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('PostRepository createPost DioException: ${e.message}');
      if (e.response != null) {
        debugPrint('PostRepository createPost error data: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      debugPrint('PostRepository createPost error: $e');
      return false;
    }
  }
}
