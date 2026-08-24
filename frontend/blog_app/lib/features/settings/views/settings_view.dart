import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';
import '../../auth/controller/auth_controller.dart';
import '../../profile/widgets/profile_menu.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ProfileMenu(
            onLogout: () {
              Get.find<AuthController>().logout();
            },
          ),
        ),
      ),
    );
  }
}
