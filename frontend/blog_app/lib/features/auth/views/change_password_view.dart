import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Your password must be at least 8 characters long.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                
                Obx(() => TextFormField(
                  controller: controller.currentPasswordController,
                  obscureText: !controller.isCurrentPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isCurrentPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => controller.isCurrentPasswordVisible.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                
                Obx(() => TextFormField(
                  controller: controller.newPasswordController,
                  obscureText: !controller.isNewPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isNewPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => controller.isNewPasswordVisible.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                
                Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_clock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => controller.isConfirmPasswordVisible.toggle(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != controller.newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 32),
                
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes', style: TextStyle(fontSize: 16)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
