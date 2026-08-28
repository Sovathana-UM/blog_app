import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_header_delegate.dart';
import '../../../core/theme/app_color.dart';
import '../widgets/profile_shimmer.dart';

import '../widgets/post_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.gradientStart,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const ProfileShimmer();
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
                    return const Center(
                      child: Text('User not found. Please log in again.'),
                    );
                  }

                  double dynamicMaxHeight = 290;
                  if (user.bio != null && user.bio!.isNotEmpty) {
                    dynamicMaxHeight +=
                        60; // Approximate 2 lines for bio + spacing
                  }
                  if (user.location != null && user.location!.isNotEmpty) {
                    dynamicMaxHeight += 24;
                  }
                  if (user.createdAt != null && user.createdAt!.isNotEmpty) {
                    dynamicMaxHeight += 24;
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadProfileData,
                    child: NestedScrollView(
                      controller: controller.scrollController,
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                            return <Widget>[
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: ProfileHeaderDelegate(
                                  user: user,
                                  onEditProfile: () {
                                    Get.toNamed('/edit-profile');
                                  },
                                  maxHeight: dynamicMaxHeight,
                                  minHeight:
                                      kToolbarHeight +
                                      MediaQuery.of(context).padding.top,
                                ),
                              ),

                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _SliverAppBarDelegate(
                                  TabBar(
                                    labelColor: AppColor.primary,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: AppColor.primary,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    indicatorWeight: 3,
                                    tabs: const [
                                      Tab(text: 'Posts'),
                                      Tab(text: 'Saved'),
                                    ],
                                  ),
                                ),
                              ),
                            ];
                          },
                      body: TabBarView(
                        children: [_buildPostsTab(), _buildSavedTab()],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return Obx(() {
      if (controller.userPosts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 60,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Posts Yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start sharing your thoughts by creating your first blog post.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    height: 1.4,
                  ),
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
          return PostCard(
            post: post,
            onLike: () => controller.toggleLike(post),
            onSave: () => controller.savePost(post),
            onShare: () => controller.sharePost(post),
          );
        },
      );
    });
  }

  Widget _buildSavedTab() {
    return Obx(() {
      if (controller.savedPosts.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    size: 60,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Saved Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Save interesting posts to read them later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    height: 1.4,
                  ),
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
          return PostCard(
            post: post,
            onLike: () => controller.toggleLike(post),
            onSave: () => controller.savePost(post),
            onShare: () => controller.sharePost(post),
          );
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
