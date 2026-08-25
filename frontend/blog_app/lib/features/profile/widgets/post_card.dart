import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/post/models/post_model.dart';
import '../../../features/post/views/post_detail_view.dart';
import '../../../core/network/dio_client.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onSave;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final String baseUrl = DioClient().dio.options.baseUrl.replaceAll('/api', '');
    final String imageUrl = '$baseUrl/storage/${post.image}';

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
            if (post.user != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: post.user!.profilePicture != null
                      ? NetworkImage('$baseUrl/storage/${post.user!.profilePicture}')
                      : null,
                  child: post.user!.profilePicture == null
                      ? Text(post.user!.firstName.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(post.user!.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_formatDate(post.createdAt), style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSaved ? const Color(0xFF2E6FF2) : Colors.grey,
                  ),
                  onPressed: onSave,
                ),
              ),
            
            // Image
            Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                );
              },
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E6FF2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.category!.name,
                        style: const TextStyle(color: Color(0xFF2E6FF2), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
}
