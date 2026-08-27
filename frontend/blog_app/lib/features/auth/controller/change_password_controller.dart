import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/auth_repository.dart';

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

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
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
        Get.back();
        Get.snackbar(
          'Success',
          response['message'] ?? 'Password changed successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to change password.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
