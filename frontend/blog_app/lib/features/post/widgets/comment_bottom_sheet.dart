import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/comment_controller.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final CommentController commentController = Get.put(CommentController());
  final TextEditingController _commentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    commentController.fetchComments(widget.postId);
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentInputController.text.trim();
    if (text.isEmpty) return;

    final success = await commentController.addComment(widget.postId, text);
    if (success) {
      _commentInputController.clear();
      FocusScope.of(context).unfocus();
    } else {
      Get.snackbar('Error', 'Failed to add comment', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (commentController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (commentController.comments.isEmpty) {
                return const Center(child: Text('No comments yet. Be the first!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  );
                },
              );
            }),
          ),
          // Input field
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
        ],
      ),
      ),
    );
  }
}
