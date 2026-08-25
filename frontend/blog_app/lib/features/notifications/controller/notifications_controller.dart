import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _repository.getNotifications();
      notifications.assignAll(data);
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      final success = await _repository.markAsRead(notification.id.toString());
      if (success) {
        final index = notifications.indexOf(notification);
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success) {
        final updated = notifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            body: n.body,
            type: n.type,
            data: n.data,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
        notifications.assignAll(updated);
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
