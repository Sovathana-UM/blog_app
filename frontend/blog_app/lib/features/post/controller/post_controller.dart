import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/post_repository.dart';
import '../../root/controller/root_controller.dart';
import '../../home/controller/home_controller.dart';

class PostController extends GetxController {
  final PostRepository _postProvider = PostRepository();
  
  final titleController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final isSubmitting = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      debugPrint('PostController pickImage error: $e');
      Get.snackbar('Error', 'Failed to pick image', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void clearImage() {
    selectedImage.value = null;
  }

  Future<void> submitPost() async {
    if (selectedImage.value == null) {
      Get.snackbar('Error', 'Please select an image', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await _postProvider.createPost(
        title: titleController.text.trim(),
        imagePath: selectedImage.value!.path,
      );

      if (success) {
        Get.snackbar('Success', 'Post created successfully', backgroundColor: Colors.green, colorText: Colors.white);
        
        // Clear form
        titleController.clear();
        selectedImage.value = null;
        
        // Refresh home posts
        if (Get.isRegistered<HomeController>()) {
          // Get.find<HomeController>().loadPosts(); // TODO: Implement Home screen
        }

        // Navigate back to Home tab
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().changePage(0);
        }
      } else {
        Get.snackbar('Error', 'Failed to create post. Please try again.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('PostController submitPost error: $e');
      Get.snackbar('Error', 'An unexpected error occurred', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
