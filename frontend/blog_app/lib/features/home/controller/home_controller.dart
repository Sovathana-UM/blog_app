import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../post/models/post_model.dart';
import '../../post/repository/post_repository.dart';

class HomeController extends GetxController {
  final PostRepository _postProvider = PostRepository();
  
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _postProvider.getPosts();
      posts.assignAll(data);
    } catch (e) {
      debugPrint('HomeController Error loading posts: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(PostModel post) async {
    try {
      final success = await _postProvider.likePost(post.id);
      if (success) {
        final index = posts.indexOf(post);
        if (index != -1) {
          final isCurrentlyLiked = post.isLiked;
          posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            content: post.content,
            image: post.image,
            createdAt: post.createdAt,
            user: post.user,
            category: post.category,
            commentsCount: post.commentsCount,
            likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
            isLiked: !isCurrentlyLiked,
            isSaved: post.isSaved,
          );
        }
      }
    } catch (e) {
      debugPrint('HomeController Error toggling like: $e');
    }
  }

  Future<void> savePost(PostModel post) async {
    try {
      final success = await _postProvider.savePost(post.id);
      if (success) {
        final index = posts.indexOf(post);
        if (index != -1) {
          final isCurrentlySaved = post.isSaved;
          posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            content: post.content,
            image: post.image,
            createdAt: post.createdAt,
            user: post.user,
            category: post.category,
            commentsCount: post.commentsCount,
            likesCount: post.likesCount,
            isLiked: post.isLiked,
            isSaved: !isCurrentlySaved,
          );
        }
      }
    } catch (e) {
      debugPrint('HomeController Error saving post: $e');
    }
  }
}
