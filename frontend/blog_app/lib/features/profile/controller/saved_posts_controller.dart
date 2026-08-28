import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../post/repository/post_repository.dart';
import '../../post/models/post_model.dart';
import 'package:flutter/foundation.dart';

class SavedPostsController extends GetxController {
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

      final result = await _postRepository.getSavedPosts();
      posts.assignAll(result);
    } catch (e) {
      debugPrint('SavedPostsController loadPosts error: $e');
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  Future<void> toggleLike(PostModel post) async {
    try {
      final success = post.isLiked
          ? await _postRepository.unlikePost(post.id)
          : await _postRepository.likePost(post.id);

      if (success) {
        final index = posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          final p = posts[index];
          posts[index] = PostModel(
            id: p.id,
            userId: p.userId,
            title: p.title,
            content: p.content,
            imageUrls: p.imageUrls,
            createdAt: p.createdAt,
            author: p.author,
            commentsCount: p.commentsCount,
            likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1,
            sharesCount: p.sharesCount,
            shareUrl: p.shareUrl,
            isLiked: !p.isLiked,
            isSaved: p.isSaved,
            sharedPost: p.sharedPost,
          );
        }
      }
    } catch (e) {
      debugPrint('SavedPostsController Error toggling like: $e');
    }
  }

  Future<void> savePost(PostModel post) async {
    try {
      final success = post.isSaved
          ? await _postRepository.unsavePost(post.id)
          : await _postRepository.savePost(post.id);

      if (success) {
        if (post.isSaved) {
          posts.removeWhere((p) => p.id == post.id);
        } else {
          loadPosts();
        }
      }
    } catch (e) {
      debugPrint('SavedPostsController Error saving post: $e');
    }
  }

  Future<void> sharePost(PostModel post) async {
    final TextEditingController contentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Share Post'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(
            hintText: 'Add a comment (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              try {
                final data = await _postRepository.sharePost(
                  post.id,
                  content: contentController.text.trim(),
                );
                if (data != null) {
                  final index = posts.indexWhere((p) => p.id == post.id);
                  if (index != -1) {
                    final p = posts[index];
                    posts[index] = PostModel(
                      id: p.id,
                      userId: p.userId,
                      title: p.title,
                      content: p.content,
                      imageUrls: p.imageUrls,
                      createdAt: p.createdAt,
                      author: p.author,
                      commentsCount: p.commentsCount,
                      likesCount: p.likesCount,
                      sharesCount: p.sharesCount + 1,
                      shareUrl: p.shareUrl,
                      isLiked: p.isLiked,
                      isSaved: p.isSaved,
                      sharedPost: p.sharedPost,
                    );
                  }
                  Get.snackbar('Success', 'Post shared successfully!');
                }
              } catch (e) {
                debugPrint('SavedPostsController Error sharing post: $e');
                Get.snackbar('Error', 'Failed to share post.');
              }
            },
            child: const Text('Share Now'),
          ),
        ],
      ),
    );
  }
}
