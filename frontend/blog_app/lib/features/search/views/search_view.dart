import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/search_controller.dart' as app_search;
import '../../../features/profile/widgets/post_card.dart';

class SearchView extends GetView<app_search.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller manually if not using bindings
    if (!Get.isRegistered<app_search.SearchController>()) {
      Get.put(app_search.SearchController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: controller.searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
          ),
          onSubmitted: controller.searchPosts,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => controller.searchPosts(controller.searchController.text),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasSearched.value && controller.searchResults.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No posts found', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        if (!controller.hasSearched.value) {
          return const Center(
            child: Text('Type something to search', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final post = controller.searchResults[index];
            return PostCard(
              post: post,
              onLike: () => controller.toggleLike(post),
              onSave: () => controller.toggleSave(post),
              onShare: () => controller.sharePost(post),
            );
          },
        );
      }),
    );
  }
}
