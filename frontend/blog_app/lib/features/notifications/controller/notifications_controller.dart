import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repository/notification_repository.dart';
import '../../post/repository/post_repository.dart';
import '../../post/views/post_detail_view.dart';
import '../../root/controller/root_controller.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  
  final ScrollController scrollController = ScrollController();
  
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchNotifications(refresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      isLoading.value = true;
    } else {
      if (!_hasMoreData || isLoadingMore.value) return;
      isLoadingMore.value = true;
    }

    hasError.value = false;
    try {
      final data = await _repository.getNotifications(page: _currentPage);
      
      if (refresh) {
        notifications.assignAll(data);
      } else {
        notifications.addAll(data);
      }

      if (data.length < 20) {
        _hasMoreData = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (refresh) hasError.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMore() {
    fetchNotifications();
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      debugPrint('Controller: Marking as read for id: ${notification.id}');
      final success = await _repository.markAsRead(notification.id.toString());
      debugPrint('Controller: markAsRead success: $success');
      if (success) {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        debugPrint('Controller: found index: $index');
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notification.id,
            type: notification.type,
            message: notification.message,
            sender: notification.sender,
            postId: notification.postId,
            isRead: true,
            createdAt: notification.createdAt,
          );
          notifications.refresh();
          
          if (Get.isRegistered<RootController>()) {
            final rootCtrl = Get.find<RootController>();
            if (rootCtrl.unreadCount.value > 0) {
              rootCtrl.unreadCount.value--;
            }
          }
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
            type: n.type,
            message: n.message,
            sender: n.sender,
            postId: n.postId,
            isRead: true,
            createdAt: n.createdAt,
          );
        }).toList();
        notifications.assignAll(updated.cast<NotificationModel>());
        
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().unreadCount.value = 0;
        }
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> navigateToPost(String postId) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final post = await PostRepository().getPost(postId);
      Get.back(); // close dialog
      if (post != null) {
        Get.to(() => PostDetailView(post: post));
      } else {
        Get.snackbar('Error', 'Failed to load post');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to load post');
    }
  }
}
