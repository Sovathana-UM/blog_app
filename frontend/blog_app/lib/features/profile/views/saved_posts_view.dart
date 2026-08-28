import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/saved_posts_controller.dart';
import '../widgets/post_card.dart';

class SavedPostsView extends GetView<SavedPostsController> {
  const SavedPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Posts'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.isError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load saved posts.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshPosts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.posts.isEmpty) {
          return const Center(
            child: Text(
              'You haven\'t saved any posts yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPosts,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              return PostCard(
                post: controller.posts[index],
                onLike: () => controller.toggleLike(controller.posts[index]),
                onSave: () => controller.savePost(controller.posts[index]),
                onShare: () => controller.sharePost(controller.posts[index]),
              );
            },
          ),
        );
      }),
    );
  }
}
