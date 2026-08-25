import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/post_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 3,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unable to load profile information.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadProfileData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = controller.currentUser;
          if (user == null) {
            return const Center(child: Text('User not found. Please log in again.'));
          }

          return RefreshIndicator(
            onRefresh: controller.loadProfileData,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    user: user,
                    onEditProfile: () {
                      Get.snackbar('Edit Profile', 'Edit profile coming soon!');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Obx(() => StatsCard(
                    totalPosts: controller.userPosts.length,
                    followers: 128, // Mock
                    following: 96,  // Mock
                  )),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
                // Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      labelColor: Color(0xFF2E6FF2),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF2E6FF2),
                      tabs: [
                        Tab(text: 'Posts'),
                        Tab(text: 'Comments'),
                        Tab(text: 'Saved'),
                      ],
                    ),
                  ),
                ),
                // Tab content
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      _buildPostsTab(),
                      const Center(child: Text('No Comments Yet')),
                      _buildSavedTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostsTab() {
    return Obx(() {
      if (controller.userPosts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Posts Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Start sharing your thoughts by creating your first blog post.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: controller.userPosts.length,
        itemBuilder: (context, index) {
          final post = controller.userPosts[index];
          return PostCard(post: post);
        },
      );
    });
  }

  Widget _buildSavedTab() {
    return Obx(() {
      if (controller.savedPosts.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Saved Posts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Save interesting posts to read them later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: controller.savedPosts.length,
        itemBuilder: (context, index) {
          final post = controller.savedPosts[index];
          return PostCard(post: post);
        },
      );
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
