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
        debugPrint('CommentRepository getComments raw data: ${response.data}');
        final Map<String, dynamic> dataMap = response.data['data'] ?? {};
        final List<dynamic> commentsData = dataMap['comments'] ?? [];
        debugPrint('CommentRepository getComments parsed comments length: ${commentsData.length}');
        return commentsData.map((json) => CommentModel.fromJson(json)).toList();
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
        '/posts/$postId/comments',
        data: {'content': content},
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('CommentRepository addComment error: $e');
      return false;
    }
  }
}
