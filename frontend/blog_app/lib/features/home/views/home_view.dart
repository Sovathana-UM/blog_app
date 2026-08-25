import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../profile/widgets/post_card.dart';
import '../../search/views/search_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Blogify', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.to(() => const SearchView());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No posts yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadPosts,
                  child: const Text('Refresh'),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadPosts,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              final post = controller.posts[index];
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post),
                onSave: () => controller.savePost(post),
              );
            },
          ),
        );
      }),
    );
  }
}
