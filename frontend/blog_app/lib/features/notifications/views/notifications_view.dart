import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notifications_controller.dart';
import '../../../core/utils/date_formatter.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('Failed to load notifications'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchNotifications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No notifications yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.notifications.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final notification = controller.notifications[index];
              return ListTile(
                tileColor: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? Colors.grey[200] : const Color(0xFF2E6FF2).withOpacity(0.2),
                  backgroundImage: notification.sender?.avatarUrl != null
                      ? NetworkImage(notification.sender!.avatarUrl!)
                      : null,
                  child: notification.sender?.avatarUrl == null
                      ? Icon(
                          notification.type == 'like' ? Icons.favorite : Icons.comment,
                          color: notification.isRead ? Colors.grey : const Color(0xFF2E6FF2),
                        )
                      : null,
                ),
                title: Text(
                  notification.sender != null
                      ? '${notification.sender!.firstName} ${notification.sender!.lastName}'
                      : 'Notification',
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification.message),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.timeAgo(notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                onTap: () {
                  controller.markAsRead(notification);
                  if (notification.postId != null) {
                    controller.navigateToPost(notification.postId!);
                  }
                },
                trailing: !notification.isRead
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2E6FF2),
                        ),
                      )
                    : null,
              );
            },
          ),
        );
      }),
    );
  }
}
