import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
      debugPrint('HomeController: Toggling like for post ${post.id}. Current isLiked: ${post.isLiked}');
      final success = post.isLiked
          ? await _postProvider.unlikePost(post.id)
          : await _postProvider.likePost(post.id);
          
      debugPrint('HomeController: Toggle like success: $success');
      if (success) {
        final index = posts.indexOf(post);
        if (index != -1) {
          final isCurrentlyLiked = post.isLiked;
          posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            content: post.content,
            imageUrls: post.imageUrls,
            createdAt: post.createdAt,
            author: post.author,
            commentsCount: post.commentsCount,
            likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
            sharesCount: post.sharesCount,
            shareUrl: post.shareUrl,
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
      debugPrint('HomeController: Toggling save for post ${post.id}. Current isSaved: ${post.isSaved}');
      final success = post.isSaved
          ? await _postProvider.unsavePost(post.id)
          : await _postProvider.savePost(post.id);
          
      debugPrint('HomeController: Toggle save success: $success');
      if (success) {
        final index = posts.indexOf(post);
        if (index != -1) {
          final isCurrentlySaved = post.isSaved;
          posts[index] = PostModel(
            id: post.id,
            userId: post.userId,
            title: post.title,
            content: post.content,
            imageUrls: post.imageUrls,
            createdAt: post.createdAt,
            author: post.author,
            commentsCount: post.commentsCount,
            likesCount: post.likesCount,
            sharesCount: post.sharesCount,
            shareUrl: post.shareUrl,
            isLiked: post.isLiked,
            isSaved: !isCurrentlySaved,
          );
        }
      }
    } catch (e) {
      debugPrint('HomeController Error saving post: $e');
    }
  }

  Future<void> sharePost(PostModel post) async {
    try {
      if (post.shareUrl != null) {
        // Open native share dialog
        await Share.share('Check out this post: ${post.shareUrl}');
        
        // Notify backend to increment count
        final data = await _postProvider.sharePost(post.id);
        if (data != null) {
          final index = posts.indexOf(post);
          if (index != -1) {
            posts[index] = PostModel(
              id: post.id,
              userId: post.userId,
              title: post.title,
              content: post.content,
              imageUrls: post.imageUrls,
              createdAt: post.createdAt,
              author: post.author,
              commentsCount: post.commentsCount,
              likesCount: post.likesCount,
              sharesCount: data['shares_count'] ?? post.sharesCount + 1,
              shareUrl: post.shareUrl,
              isLiked: post.isLiked,
              isSaved: post.isSaved,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('HomeController Error sharing post: $e');
    }
  }
}
