import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/views/post_detail_view.dart';
import '../../../features/auth/controller/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/post/repository/post_repository.dart';
import '../../../features/home/controller/home_controller.dart';
import '../../../features/profile/controller/profile_controller.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = Get.isRegistered<AuthController>() 
        ? Get.find<AuthController>().currentUser.value?.id 
        : null;
    final isOwner = currentUserId != null && post.author?.id == currentUserId;

    return GestureDetector(
      onTap: () {
        Get.to(() => PostDetailView(post: post));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Header
            if (post.author != null)
              ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: post.author!.avatarUrl != null
                          ? NetworkImage(post.author!.avatarUrl!)
                          : null,
                      child: post.author!.avatarUrl == null
                          ? Text(post.author!.firstName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: post.author!.isOnline ? Colors.green : Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(post.author!.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_formatDate(post.createdAt), style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: post.isSaved ? const Color(0xFF2E6FF2) : Colors.grey,
                      ),
                      onPressed: onSave,
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Get.toNamed(Routes.EDIT_POST, arguments: post);
                          } else if (value == 'delete') {
                            Get.defaultDialog(
                              title: 'Delete Post',
                              middleText: 'Are you sure you want to delete this post?',
                              textConfirm: 'Delete',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.redAccent,
                              onConfirm: () async {
                                Get.back(); // close dialog
                                final success = await PostRepository().deletePost(post.id.toString());
                                if (success) {
                                  Get.snackbar('Success', 'Post deleted', backgroundColor: Colors.green, colorText: Colors.white);
                                  if (Get.isRegistered<HomeController>()) Get.find<HomeController>().loadPosts();
                                  if (Get.isRegistered<ProfileController>()) Get.find<ProfileController>().getUserPosts();
                                } else {
                                  Get.snackbar('Error', 'Failed to delete post', backgroundColor: Colors.redAccent, colorText: Colors.white);
                                }
                              },
                              textCancel: 'Cancel',
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            
            // Image Carousel (or first image)
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 180,
                child: PageView.builder(
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      post.imageUrls[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        );
                      },
                    );
                  },
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (post.title != null && post.title!.isNotEmpty) ...[
                    Text(
                      post.title!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (post.content != null && post.content!.isNotEmpty) ...[
                    Text(
                      post.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (post.sharedPost != null) ...[
                    _buildEmbeddedPost(post.sharedPost!),
                    const SizedBox(height: 12),
                  ] else if (post.sharedPostId != null) ...[
                    _buildUnavailablePost(),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: onLike,
                            child: Row(
                              children: [
                                Icon(
                                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: post.isLiked ? Colors.red : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text('${post.likesCount}', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('${post.commentsCount}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: onShare,
                            child: Row(
                              children: [
                                Icon(Icons.share_outlined, size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('${post.sharesCount}', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Recent';
    }
  }

  Widget _buildEmbeddedPost(PostModel sharedPost) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sharedPost.author != null)
            ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundImage: sharedPost.author!.avatarUrl != null
                    ? NetworkImage(sharedPost.author!.avatarUrl!)
                    : null,
                child: sharedPost.author!.avatarUrl == null
                    ? Text(sharedPost.author!.firstName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12))
                    : null,
              ),
              title: Text(sharedPost.author!.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(_formatDate(sharedPost.createdAt), style: const TextStyle(fontSize: 12)),
              dense: true,
            ),
          
          if (sharedPost.imageUrls.isNotEmpty)
            Image.network(
              sharedPost.imageUrls.first,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                );
              },
            ),

          if (sharedPost.title != null || sharedPost.content != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sharedPost.title != null && sharedPost.title!.isNotEmpty) ...[
                    Text(
                      sharedPost.title!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (sharedPost.content != null && sharedPost.content!.isNotEmpty)
                    Text(
                      sharedPost.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnavailablePost() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.grey[500], size: 32),
          const SizedBox(height: 8),
          Text(
            'This content isn\'t available right now',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'When this happens, it\'s usually because the owner only shared it with a small group of people, changed who can see it or it\'s been deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
