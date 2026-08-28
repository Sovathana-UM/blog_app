import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/repository/post_repository.dart';
import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

class SearchController extends GetxController {
  final DioClient _dioClient = DioClient();
  final PostRepository _postProvider = PostRepository();

  final searchController = TextEditingController();
  final RxList<PostModel> searchResults = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    hasSearched.value = true;

    try {
      final response = await _dioClient.dio.get(
        '/posts/search',
        queryParameters: {'q': query},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['posts'] ?? [];
        searchResults.assignAll(
          data.map((e) => PostModel.fromJson(e)).toList(),
        );
      }
    } on DioException catch (e) {
      debugPrint('Search error: $e');
      Get.snackbar(
        'Error',
        'Failed to search posts',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updatePost(PostModel oldPost, PostModel Function(PostModel) updater) {
    final index = searchResults.indexWhere((p) => p.id == oldPost.id);
    if (index != -1) {
      searchResults[index] = updater(searchResults[index]);
    }
  }

  PostModel _copyPostWith(
    PostModel post, {
    bool? isLiked,
    int? likesCount,
    bool? isSaved,
    int? sharesCount,
  }) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      content: post.content,
      imageUrls: post.imageUrls,
      createdAt: post.createdAt,
      author: post.author,
      commentsCount: post.commentsCount,
      likesCount: likesCount ?? post.likesCount,
      sharesCount: sharesCount ?? post.sharesCount,
      shareUrl: post.shareUrl,
      isLiked: isLiked ?? post.isLiked,
      isSaved: isSaved ?? post.isSaved,
      sharedPost: post.sharedPost,
    );
  }

  Future<void> toggleLike(PostModel post) async {
    try {
      final success = post.isLiked
          ? await _postProvider.unlikePost(post.id)
          : await _postProvider.likePost(post.id);

      if (success) {
        final newIsLiked = !post.isLiked;
        _updatePost(post, (p) {
          return _copyPostWith(
            p,
            isLiked: newIsLiked,
            likesCount: newIsLiked ? p.likesCount + 1 : p.likesCount - 1,
          );
        });
      }
    } catch (e) {
      debugPrint('SearchController Error toggling like: $e');
    }
  }

  Future<void> toggleSave(PostModel post) async {
    try {
      final success = post.isSaved
          ? await _postProvider.unsavePost(post.id)
          : await _postProvider.savePost(post.id);

      if (success) {
        _updatePost(post, (p) {
          return _copyPostWith(p, isSaved: !post.isSaved);
        });
      }
    } catch (e) {
      debugPrint('SearchController Error toggling save: $e');
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
              Get.back();
              try {
                final data = await _postProvider.sharePost(
                  post.id,
                  content: contentController.text.trim(),
                );

                if (data != null) {
                  _updatePost(post, (p) {
                    return _copyPostWith(p, sharesCount: p.sharesCount + 1);
                  });
                  Get.snackbar('Success', 'Post shared successfully!');
                }
              } catch (e) {
                debugPrint('SearchController Error sharing post: $e');
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
