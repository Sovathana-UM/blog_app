import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/local_notification_service.dart';

class RootController extends GetxController {
  final currentIndex = 0.obs;
  final unreadCount = 0.obs;
  final DioClient _dioClient = DioClient();

  @override
  void onInit() {
    super.onInit();
    _fetchUnreadCount();
    _setupFcmListener();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final response = await _dioClient.dio.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data['success'] == true) {
        unreadCount.value = response.data['data']['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('RootController _fetchUnreadCount error: $e');
    }
  }

  void _setupFcmListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('RootController received FCM foreground message: ${message.messageId}');
      // Increment the badge count when a push notification arrives while app is open
      unreadCount.value++;
      
      // Show native system banner
      LocalNotificationService.showNotification(message);
    });
  }

  void changePage(int index) {
    if (index != 2) {
      currentIndex.value = index;
    }
    if (index == 1) {
      // If navigating to notifications, we can optionally trigger a refresh or clear badge
      // But typically NotificationsController will handle marking as read.
    }
  }
}
