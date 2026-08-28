import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/post_repository.dart';
import '../../root/controller/root_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../profile/controller/profile_controller.dart';

class PostController extends GetxController {
  final PostRepository _postProvider = PostRepository();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final RxList<File> selectedImages = <File>[].obs;

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        selectedImages.addAll(images.map((image) => File(image.path)));
      }
    } catch (e) {
      debugPrint('PostController pickImages error: $e');
      Get.snackbar(
        'Error',
        'Failed to pick images',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void clearImages() {
    selectedImages.clear();
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  Future<void> submitPost() async {
    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one image',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (contentController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Content is required',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await _postProvider.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        imagePaths: selectedImages.map((file) => file.path).toList(),
      );

      if (success) {
        // Clear form
        titleController.clear();
        contentController.clear();
        selectedImages.clear();

        // Refresh home posts
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadPosts();
        }

        // Refresh profile posts
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getUserPosts();
        }

        // Navigate back to Home tab
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().changePage(0);
        }

        // Close the create post screen
        Get.back();

        // Show snackbar
        Get.snackbar(
          'Success',
          'Post created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create post. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('PostController submitPost error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
