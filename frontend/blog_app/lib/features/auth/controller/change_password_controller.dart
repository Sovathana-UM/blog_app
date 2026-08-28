import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/auth_repository.dart';
import 'auth_controller.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;

  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final RxString currentPasswordError = ''.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    currentPasswordError.value = '';
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authRepository.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
        confirmPasswordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Password changed successfully. Please login again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Logout the user and redirect to login screen
        final authController = Get.find<AuthController>();
        authController.logout();
      } else {
        currentPasswordError.value =
            response['message'] ?? 'Incorrect current password.';
        formKey.currentState!.validate();
      }
    } catch (e) {
      currentPasswordError.value =
          'Failed to change password. Please check your current password.';
      formKey.currentState!.validate();
    } finally {
      isLoading.value = false;
    }
  }
}
