import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/repository/post_repository.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final PostRepository _postProvider = PostRepository();

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxList<PostModel> userPosts = <PostModel>[].obs;
  final RxList<PostModel> savedPosts = <PostModel>[].obs;

  UserModel? get currentUser => authController.currentUser.value;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      await authController.refreshCurrentUser();
      if (currentUser != null) {
        await Future.wait([
          getUserPosts(),
          getSavedPosts(),
        ]);
      }
    } catch (e) {
      debugPrint('ProfileController Error loading profile: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserPosts() async {
    try {
      final posts = await _postProvider.getMyPosts();
      userPosts.assignAll(posts);
    } catch (e) {
      debugPrint('ProfileController Error fetching posts: $e');
      hasError.value = true;
    }
  }

  Future<void> getSavedPosts() async {
    try {
      final posts = await _postProvider.getSavedPosts();
      savedPosts.assignAll(posts);
    } catch (e) {
      debugPrint('ProfileController Error fetching saved posts: $e');
    }
  }

  void logout() {
    authController.logout();
  }
}
