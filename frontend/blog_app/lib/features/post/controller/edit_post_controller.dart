import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repository/post_repository.dart';
import '../models/post_model.dart';
import '../../home/controller/home_controller.dart';
import '../../profile/controller/profile_controller.dart';

class EditPostController extends GetxController {
  final PostRepository _postProvider = PostRepository();

  late final PostModel post;
  final contentController = TextEditingController();
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get post from arguments
    post = Get.arguments as PostModel;
    contentController.text = post.content ?? '';
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }

  Future<void> submitEdit() async {
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
      final success = await _postProvider.updatePost(
        postId: post.id.toString(),
        content: contentController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Post updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh home posts
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadPosts();
        }

        // Refresh profile posts
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().getUserPosts();
        }

        // Navigate back
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update post. Please try again.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('EditPostController submitEdit error: $e');
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
