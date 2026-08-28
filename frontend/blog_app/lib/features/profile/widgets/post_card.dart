import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/views/post_detail_view.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../features/auth/controller/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/post/repository/post_repository.dart';
import '../../../features/home/controller/home_controller.dart';
import '../../../features/profile/controller/profile_controller.dart';
import '../../../core/theme/app_color.dart';
import 'post_image_grid.dart';

class PostCard extends StatefulWidget {
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
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isTextExpanded = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final currentUserId = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().currentUser.value?.id
        : null;
    final isOwner = currentUserId != null && post.author?.id == currentUserId;

    return GestureDetector(
      onTap: () {
        Get.to(() => PostDetailView(post: post));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Header
            if (post.author != null)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.primary.withOpacity(0.1),
                      backgroundImage: post.author!.avatarUrl != null
                          ? NetworkImage(post.author!.avatarUrl!)
                          : null,
                      child: post.author!.avatarUrl == null
                          ? Text(
                              post.author!.firstName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: post.author!.isOnline
                              ? Colors.green
                              : Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  post.author!.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  DateFormatter.timeAgo(post.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: post.isSaved
                            ? AppColor.primary
                            : Colors.grey.shade400,
                        size: 26,
                      ),
                      onPressed: widget.onSave,
                    ),
                    if (isOwner)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.grey.shade400,
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Get.toNamed(Routes.EDIT_POST, arguments: post);
                          } else if (value == 'delete') {
                            Get.defaultDialog(
                              title: 'Delete Post',
                              middleText:
                                  'Are you sure you want to delete this post?',
                              textConfirm: 'Delete',
                              confirmTextColor: Colors.white,
                              buttonColor: Colors.redAccent,
                              onConfirm: () async {
                                Get.back(); // close dialog
                                final success = await PostRepository()
                                    .deletePost(post.id.toString());
                                if (success) {
                                  Get.snackbar(
                                    'Success',
                                    'Post deleted',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                  if (Get.isRegistered<HomeController>())
                                    Get.find<HomeController>().loadPosts();
                                  if (Get.isRegistered<ProfileController>())
                                    Get.find<ProfileController>()
                                        .getUserPosts();
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to delete post',
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
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
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            // Image Grid
            if (post.imageUrls.isNotEmpty)
              PostImageGrid(imageUrls: post.imageUrls),

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
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (post.content != null && post.content!.isNotEmpty) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final style = TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.4,
                        );
                        final span = TextSpan(
                          text: post.content!,
                          style: style,
                        );
                        final tp = TextPainter(
                          text: span,
                          maxLines: 3,
                          textDirection: TextDirection.ltr,
                        );
                        tp.layout(maxWidth: constraints.maxWidth);

                        if (tp.didExceedMaxLines) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.content!,
                                maxLines: _isTextExpanded ? null : 3,
                                overflow: _isTextExpanded
                                    ? null
                                    : TextOverflow.ellipsis,
                                style: style,
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isTextExpanded = !_isTextExpanded;
                                  });
                                },
                                child: Text(
                                  _isTextExpanded ? "See less" : "See more",
                                  style: const TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text(post.content!, style: style);
                        }
                      },
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

                  // Action Buttons
                  Row(
                    children: [
                      _buildActionChip(
                        icon: post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        iconColor: post.isLiked
                            ? Colors.redAccent
                            : Colors.grey.shade600,
                        label: '${post.likesCount} Likes',
                        onTap: widget.onLike,
                      ),
                      const SizedBox(width: 12),
                      _buildActionChip(
                        icon: Icons.chat_bubble_outline,
                        iconColor: Colors.grey.shade600,
                        label: '${post.commentsCount} Comments',
                        onTap: () {
                          Get.to(
                            () =>
                                PostDetailView(post: post, focusComment: true),
                          );
                        },
                      ),
                      const Spacer(),
                      _buildActionChip(
                        icon: Icons.share_outlined,
                        iconColor: Colors.grey.shade600,
                        label: '${post.sharesCount}',
                        onTap: widget.onShare,
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

  Widget _buildActionChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedPost(PostModel sharedPost) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sharedPost.author != null)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 0.0,
              ),
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                backgroundImage: sharedPost.author!.avatarUrl != null
                    ? NetworkImage(sharedPost.author!.avatarUrl!)
                    : null,
                child: sharedPost.author!.avatarUrl == null
                    ? Text(
                        sharedPost.author!.firstName
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                        ),
                      )
                    : null,
              ),
              title: Text(
                sharedPost.author!.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                DateFormatter.timeAgo(sharedPost.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
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
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),

          if (sharedPost.title != null || sharedPost.content != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sharedPost.title != null &&
                      sharedPost.title!.isNotEmpty) ...[
                    Text(
                      sharedPost.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (sharedPost.content != null &&
                      sharedPost.content!.isNotEmpty)
                    Text(
                      sharedPost.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
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
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            'This content isn\'t available right now',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'When this happens, it\'s usually because the owner only shared it with a small group of people, changed who can see it or it\'s been deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
