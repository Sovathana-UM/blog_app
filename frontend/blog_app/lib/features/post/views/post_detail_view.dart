import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/post_model.dart';
import '../controller/comment_controller.dart';

class PostDetailView extends StatefulWidget {
  final PostModel post;
  
  const PostDetailView({super.key, required this.post});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final CommentController commentController = Get.put(CommentController());
  final TextEditingController _commentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentController.fetchComments(widget.post.id.toString());
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;

    final success = await commentController.addComment(widget.post.id.toString(), text);
    if (success) {
      _commentInputController.clear();
      FocusScope.of(context).unfocus();
    } else {
      Get.snackbar('Error', 'Failed to add comment', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Detail'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        itemCount: widget.post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.post.imageUrls[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        if (widget.post.title != null) ...[
                          Text(
                            widget.post.title!,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (widget.post.author != null)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: widget.post.author!.avatarUrl != null
                                    ? NetworkImage(widget.post.author!.avatarUrl!)
                                    : null,
                                child: widget.post.author!.avatarUrl == null
                                    ? Text(widget.post.author!.firstName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 12))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(widget.post.author!.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        const SizedBox(height: 16),
                        if (widget.post.content != null)
                          Text(
                            widget.post.content!,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        const Divider(height: 32),
                        const Text(
                          'Comments',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (commentController.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (commentController.comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No comments yet. Be the first!'),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: commentController.comments.length,
                            itemBuilder: (context, index) {
                              final comment = commentController.comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: comment.user?.avatarUrl != null
                                      ? NetworkImage(comment.user!.avatarUrl!)
                                      : null,
                                  child: comment.user?.avatarUrl == null
                                      ? Text(comment.user?.firstName.substring(0, 1).toUpperCase() ?? 'U')
                                      : null,
                                ),
                                title: Text(comment.user?.fullName ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(comment.content),
                                contentPadding: EdgeInsets.zero,
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentInputController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF2E6FF2)),
                    onPressed: _submitComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
