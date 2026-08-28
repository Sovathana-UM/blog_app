import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_tile.dart';

import 'package:blog_app/core/theme/app_color.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Content'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.article_outlined,
                    iconBgColor: AppColor.infoBg,
                    iconColor: AppColor.info,
                    title: 'My Posts',
                    subtitle: 'View and manage your posts',
                    onTap: () => Get.toNamed(Routes.MY_POSTS),
                  ),
                  SettingsTile(
                    icon: Icons.bookmark_border,
                    iconBgColor: AppColor.warningBg,
                    iconColor: AppColor.warning,
                    title: 'Saved Posts',
                    subtitle: 'Posts you have bookmarked',
                    onTap: () => Get.toNamed(Routes.SAVED_POSTS),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Security & Account'),
              SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.lock_outline,
                    iconBgColor: AppColor.successBg,
                    iconColor: AppColor.success,
                    title: 'Change Password',
                    subtitle: 'Update your login password',
                    onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                  ),
                  SettingsTile(
                    icon: Icons.logout_rounded,
                    iconBgColor: AppColor.errorBg,
                    iconColor: AppColor.error,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    titleColor: AppColor.error,
                    onTap: () {
                      _showLogoutConfirmation();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Blog App Version 1.0.2',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColor.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColor.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign Out',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to sign out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColor.borderMedium),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.find<AuthController>().logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
