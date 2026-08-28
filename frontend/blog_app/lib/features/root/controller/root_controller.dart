import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/local_notification_service.dart';
import '../../home/controller/home_controller.dart';
import '../../notifications/controller/notifications_controller.dart';

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
      debugPrint(
        'RootController received FCM foreground message: ${message.messageId}',
      );
      // Increment the badge count when a push notification arrives while app is open
      unreadCount.value++;

      // Auto refresh notifications list if the controller is active
      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().fetchNotifications(
          refresh: true,
          background: true,
        );
      }

      // Show native system banner
      LocalNotificationService.showNotification(message);
    });
  }

  void changePage(int index) {
    if (index == 0 && currentIndex.value == 0) {
      // Already on Home tab, scroll to top and refresh
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (homeController.scrollController.hasClients) {
          homeController.scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        // Programmatically trigger the refresh indicator which calls loadPosts
        homeController.refreshIndicatorKey.currentState?.show();
      }
    }

    if (index != 2) {
      currentIndex.value = index;
    }
    if (index == 1) {
      if (Get.isRegistered<NotificationsController>()) {
        final notifController = Get.find<NotificationsController>();
        if (currentIndex.value == 1) {
          if (notifController.scrollController.hasClients) {
            notifController.scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          notifController.refreshIndicatorKey.currentState?.show();
        } else {
          notifController.fetchNotifications(refresh: true, background: true);
        }
      }
    }
  }
}
