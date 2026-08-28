import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../profile/widgets/post_card.dart';
import '../../search/views/search_view.dart';
import '../../auth/controller/auth_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Obx(() {
          final authController = Get.find<AuthController>();
          final firstName = authController.currentUser.value?.firstName ?? 'User';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $firstName',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Text(
                'Discover and read amazing posts',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );
        }),
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
            controller: controller.scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: controller.posts.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final post = controller.posts[index];
              return PostCard(
                post: post,
                onLike: () => controller.toggleLike(post),
                onSave: () => controller.savePost(post),
                onShare: () => controller.sharePost(post),
              );
            },
          ),
        );
      }),
    );
  }
}
