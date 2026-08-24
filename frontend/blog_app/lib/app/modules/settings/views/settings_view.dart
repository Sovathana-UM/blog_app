import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Content'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.find<AuthController>().logout(),
              child: const Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
