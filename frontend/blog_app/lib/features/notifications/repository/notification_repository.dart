import '../../../core/network/dio_client.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationRepository {
  final DioClient _dioClient = DioClient();

  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final response = await _dioClient.dio.get('/notifications', queryParameters: {'page': page});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['notifications'] ?? [];
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load notifications');
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      debugPrint('Marking notification $id as read');
      final response = await _dioClient.dio.patch('/notifications/$id/read');
      debugPrint('markAsRead response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('markAsRead DioException: ${e.message} - ${e.response?.data}');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _dioClient.dio.patch('/notifications/read-all');
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    }
  }
}
