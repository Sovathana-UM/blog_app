import 'package:get/get.dart';
import '../../post/repository/post_repository.dart';
import '../../post/models/post_model.dart';
import 'package:flutter/foundation.dart';

class MyPostsController extends GetxController {
  final PostRepository _postRepository = PostRepository();
  
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      isError.value = false;
      
      final result = await _postRepository.getMyPosts();
      posts.assignAll(result);
    } catch (e) {
      debugPrint('MyPostsController loadPosts error: $e');
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }
}
