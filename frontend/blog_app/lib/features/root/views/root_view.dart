import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../controller/root_controller.dart';
import '../../home/views/home_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../settings/views/settings_view.dart';
import '../../profile/views/profile_view.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Here we will eventually switch between Home, Notifications, Settings, Profile views.
        // For now, placeholders.
        switch (controller.currentIndex.value) {
          case 0:
            return const HomeView();
          case 1:
            return const NotificationsView();
          case 3:
            return const SettingsView();
          case 4:
            return const ProfileView();
          default:
            return const HomeView();
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.POST);
        },
        backgroundColor: const Color(0xFF2E6FF2),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E6FF2),
          unselectedItemColor: const Color(0xFF94A3B8),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Obx(() => Badge(
                isLabelVisible: controller.unreadCount.value > 0,
                label: Text(controller.unreadCount.value.toString()),
                child: const Icon(Icons.notifications_none),
              )),
              activeIcon: Obx(() => Badge(
                isLabelVisible: controller.unreadCount.value > 0,
                label: Text(controller.unreadCount.value.toString()),
                child: const Icon(Icons.notifications),
              )),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''), // Invisible placeholder for FAB
            const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
