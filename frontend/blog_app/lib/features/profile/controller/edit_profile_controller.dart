import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/repository/auth_repository.dart';
import '../controller/profile_controller.dart';

class EditProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AuthRepository _authRepository = AuthRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final bioController = TextEditingController();
  final locationController = TextEditingController();

  final Rx<File?> selectedAvatar = Rx<File?>(null);
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final user = _authController.currentUser.value;
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      bioController.text = user.bio ?? '';
      locationController.text = user.location ?? '';
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedAvatar.value = File(image.path);
      }
    } catch (e) {
      debugPrint('EditProfileController pickAvatar error: $e');
      Get.snackbar('Error', 'Failed to pick image', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> submit() async {
    if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'First name and Last name are required', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final response = await _authRepository.updateFullProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        bio: bioController.text.trim(),
        location: locationController.text.trim(),
        avatarPath: selectedAvatar.value?.path,
      );

      if (response['success'] == true) {
        // Refresh the current user inside AuthController so changes reflect app-wide
        await _authController.refreshCurrentUser();
        
        // Refresh the profile data
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfileData();
        }

        Get.back(); // Go back to profile view
        Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update profile', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('EditProfileController submit error: $e');
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
