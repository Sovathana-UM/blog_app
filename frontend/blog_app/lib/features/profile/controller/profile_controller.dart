import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/repository/post_repository.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> toggleLike(PostModel post) async {
    try {
      debugPrint('ProfileController: Toggling like for post ${post.id}. Current isLiked: ${post.isLiked}');
      final success = post.isLiked 
          ? await _postProvider.unlikePost(post.id)
          : await _postProvider.likePost(post.id);
          
      debugPrint('ProfileController: Toggle like success: $success');
      if (success) {
        // Update in userPosts
        _updatePostInList(userPosts, post, (p) {
          return _copyPostWith(p, likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1, isLiked: !p.isLiked);
        });
        // Update in savedPosts
        _updatePostInList(savedPosts, post, (p) {
          return _copyPostWith(p, likesCount: p.isLiked ? p.likesCount - 1 : p.likesCount + 1, isLiked: !p.isLiked);
        });
      }
    } catch (e) {
      debugPrint('ProfileController Error toggling like: $e');
    }
  }

  Future<void> savePost(PostModel post) async {
    try {
      debugPrint('ProfileController: Toggling save for post ${post.id}. Current isSaved: ${post.isSaved}');
      final success = post.isSaved
          ? await _postProvider.unsavePost(post.id)
          : await _postProvider.savePost(post.id);
          
      debugPrint('ProfileController: Toggle save success: $success');
      if (success) {
        _updatePostInList(userPosts, post, (p) {
          return _copyPostWith(p, isSaved: !p.isSaved);
        });
        _updatePostInList(savedPosts, post, (p) {
          return _copyPostWith(p, isSaved: !p.isSaved);
        });
        
        // If unsaved, maybe remove from savedPosts list? 
        if (post.isSaved) {
          savedPosts.removeWhere((p) => p.id == post.id);
        } else {
          // If saved, reload saved posts
          getSavedPosts();
        }
      }
    } catch (e) {
      debugPrint('ProfileController Error saving post: $e');
    }
  }

  Future<void> sharePost(PostModel post) async {
    try {
      if (post.shareUrl != null) {
        await Share.share('Check out this post: ${post.shareUrl}');
        
        final data = await _postProvider.sharePost(post.id);
        if (data != null) {
          _updatePostInList(userPosts, post, (p) {
            return _copyPostWith(p, sharesCount: data['shares_count'] ?? p.sharesCount + 1);
          });
          _updatePostInList(savedPosts, post, (p) {
            return _copyPostWith(p, sharesCount: data['shares_count'] ?? p.sharesCount + 1);
          });
        }
      }
    } catch (e) {
      debugPrint('ProfileController Error sharing post: $e');
    }
  }

  void _updatePostInList(RxList<PostModel> list, PostModel oldPost, PostModel Function(PostModel) updater) {
    final index = list.indexWhere((p) => p.id == oldPost.id);
    if (index != -1) {
      list[index] = updater(list[index]);
    }
  }

  PostModel _copyPostWith(PostModel p, {int? likesCount, bool? isLiked, bool? isSaved, int? sharesCount}) {
    return PostModel(
      id: p.id,
      userId: p.userId,
      title: p.title,
      content: p.content,
      imageUrls: p.imageUrls,
      createdAt: p.createdAt,
      author: p.author,
      commentsCount: p.commentsCount,
      likesCount: likesCount ?? p.likesCount,
      sharesCount: sharesCount ?? p.sharesCount,
      shareUrl: p.shareUrl,
      isLiked: isLiked ?? p.isLiked,
      isSaved: isSaved ?? p.isSaved,
    );
  }
}
