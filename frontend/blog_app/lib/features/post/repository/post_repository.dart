import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../../../core/network/dio_client.dart';

class PostRepository {
  final Dio _dio = DioClient().dio;

  Future<List<PostModel>> getPosts({String? userId, int page = 1}) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _dio.get('/posts', queryParameters: queryParams);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['posts'];
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

  Future<PostModel?> getPost(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return PostModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('PostRepository getPost error: $e');
      return null;
    }
  }

  Future<List<PostModel>> getMyPosts({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/posts/my-posts',
        queryParameters: {'page': page},
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['posts'];
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
        final List<dynamic> data = response.data['data']['posts'];
        return data.map((json) => PostModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('PostRepository getSavedPosts error: $e');
      return [];
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      debugPrint('PostRepository: likePost $postId');
      final response = await _dio.post('/posts/$postId/like');
      debugPrint('PostRepository: likePost response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('PostRepository: likePost error: $e');
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      debugPrint('PostRepository: unlikePost $postId');
      final response = await _dio.delete('/posts/$postId/like');
      debugPrint('PostRepository: unlikePost response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('PostRepository: unlikePost error: $e');
      return false;
    }
  }

  Future<bool> savePost(String postId) async {
    try {
      debugPrint('PostRepository: savePost $postId');
      final response = await _dio.post('/posts/$postId/save');
      debugPrint('PostRepository: savePost response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('PostRepository: savePost error: $e');
      return false;
    }
  }

  Future<bool> unsavePost(String postId) async {
    try {
      debugPrint('PostRepository: unsavePost $postId');
      final response = await _dio.delete('/posts/$postId/save');
      debugPrint('PostRepository: unsavePost response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('PostRepository: unsavePost error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> sharePost(
    String postId, {
    String? content,
  }) async {
    try {
      final response = await _dio.post(
        '/posts/$postId/share',
        data: content != null && content.isNotEmpty
            ? {'content': content}
            : null,
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      debugPrint('PostRepository sharePost error: $e');
      return null;
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
    required List<String> imagePaths,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (title.isNotEmpty) 'title': title,
        if (content.isNotEmpty) 'content': content,
      });

      for (String path in imagePaths) {
        String fileName = path.split('/').last;
        if (!fileName.contains('.')) {
          fileName = '$fileName.jpg';
        }
        formData.files.add(
          MapEntry(
            'images[]',
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

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

  Future<bool> updatePost({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '/posts/$postId',
        data: {'content': content},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('PostRepository updatePost error: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      final response = await _dio.delete('/posts/$postId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('PostRepository deletePost error: $e');
      return false;
    }
  }
}
