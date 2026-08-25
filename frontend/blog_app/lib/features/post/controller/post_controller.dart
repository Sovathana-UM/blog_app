import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/post_repository.dart';
import '../models/category_model.dart';
import '../../root/controller/root_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../profile/controller/profile_controller.dart';

class PostController extends GetxController {
  final PostRepository _postProvider = PostRepository();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final Rx<File?> selectedImage = Rx<File?>(null);
  
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    final list = await _postProvider.getCategories();
    categories.assignAll(list);
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
    if (contentController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Content is required', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final success = await _postProvider.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        categoryId: selectedCategory.value?.id,
        imagePath: selectedImage.value!.path,
      );

      if (success) {
        Get.snackbar('Success', 'Post created successfully', backgroundColor: Colors.green, colorText: Colors.white);

        // Clear form
        titleController.clear();
        contentController.clear();
        selectedCategory.value = null;
        selectedImage.value = null;

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
