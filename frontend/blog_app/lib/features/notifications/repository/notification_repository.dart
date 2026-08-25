import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationRepository {
  final DioClient _dioClient = DioClient();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dioClient.dio.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load notifications');
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dioClient.dio.post('/notifications/$id/read');
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _dioClient.dio.post('/notifications/read-all');
      return response.statusCode == 200;
    } on DioException catch (_) {
      return false;
    }
  }
}
