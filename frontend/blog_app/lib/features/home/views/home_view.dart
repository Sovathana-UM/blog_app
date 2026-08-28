import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../../profile/widgets/post_card.dart';
import '../../search/views/search_view.dart';
import '../../auth/controller/auth_controller.dart';
import '../../root/controller/root_controller.dart';
import '../../../core/theme/app_color.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Obx(() {
          final authController = Get.find<AuthController>();
          final user = authController.currentUser.value;
          final firstName = user?.firstName ?? 'User';
          return GestureDetector(
            onTap: () {
              if (Get.isRegistered<RootController>()) {
                Get.find<RootController>().changePage(4);
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  backgroundColor: AppColor.primary.withOpacity(0.1),
                  child: user?.avatarUrl == null
                      ? Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName 👋',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Ready to discover something new?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        centerTitle: false,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
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
          return ListView.builder(
            itemCount: 3,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemBuilder: (context, index) {
              return const PostSkeleton();
            },
          );
        }

        if (controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_outlined,
                    size: 72,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No posts to show',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Follow people or check back later\nfor new content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: controller.loadPosts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Feed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          key: controller.refreshIndicatorKey,
          onRefresh: controller.loadPosts,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount:
                controller.posts.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                return const PostSkeleton();
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

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 14, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 80, height: 10, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            Container(height: 220, width: double.infinity, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(width: 200, height: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
