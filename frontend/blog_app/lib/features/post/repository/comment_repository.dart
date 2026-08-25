import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../../../core/network/dio_client.dart';

class CommentRepository {
  final Dio _dio = DioClient().dio;

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => CommentModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('CommentRepository getComments error: $e');
      return [];
    }
  }

  Future<bool> addComment(String postId, String content) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {'post_id': postId, 'content': content},
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('CommentRepository addComment error: $e');
      return false;
    }
  }
}
