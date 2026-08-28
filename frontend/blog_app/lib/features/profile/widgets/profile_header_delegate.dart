import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/theme/app_color.dart';

class ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final UserModel user;
  final VoidCallback onEditProfile;
  final double maxHeight;
  final double minHeight;

  ProfileHeaderDelegate({
    required this.user,
    required this.onEditProfile,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant ProfileHeaderDelegate oldDelegate) {
    return oldDelegate.user != user ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.minHeight != minHeight;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0.0 = fully expanded, 1.0 = fully collapsed
    double progress = shrinkOffset / (maxExtent - minExtent);
    progress = progress.clamp(0.0, 1.0);

    final String? avatarUrl = user.avatarUrl;
    final String emailText = user.email;

    // Opacity for fading out text quickly (between 0.0 and 0.5 progress)
    final double contentOpacity = (1.0 - (progress * 2)).clamp(0.0, 1.0);

    // Opacity for fading in the small header text (between 0.8 and 1.0 progress)
    final double smallTitleOpacity = ((progress - 0.8) * 5).clamp(0.0, 1.0);

    // Avatar animation logic
    // Max size: 92 (radius 46 * 2)
    // Min size: 36
    final double currentAvatarSize = 92 - (56 * progress);

    // Avatar X position:
    // When expanded, centered (screenWidth / 2 - avatarSize / 2)
    // When collapsed, left aligned (approx 16 padding)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double expandedAvatarX = screenWidth / 2 - (currentAvatarSize / 2);
    final double collapsedAvatarX = 16.0;
    final double currentAvatarX =
        expandedAvatarX - ((expandedAvatarX - collapsedAvatarX) * progress);

    // Avatar Y position:
    // When expanded, sits on the border of blue/white (100 - avatarSize / 2)
    // When collapsed, centered in the minHeight appbar
    final double topSafePadding = MediaQuery.of(context).padding.top;
    final double expandedAvatarY = 100 - (92 / 2); // 54
    final double collapsedAvatarY = topSafePadding + (kToolbarHeight - 36) / 2;
    final double currentAvatarY =
        expandedAvatarY - ((expandedAvatarY - collapsedAvatarY) * progress);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Blue Background
        Container(
          height:
              maxExtent, // Fill the space, but it will be clipped by the sliver
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.gradientStart, AppColor.gradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 2. White Card Content (fades out and slides up slightly)
        Positioned(
          top: 100 - (shrinkOffset * 0.5), // slight parallax
          left: 0,
          right: 0,
          bottom:
              0, // ensure it ends at the sliver boundary so tabs are visible
          child: Opacity(
            opacity: contentOpacity,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 60.0,
                  bottom: 24.0,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Text(
                        emailText,
                        style: const TextStyle(
                          color: AppColor.textProfileLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColor.textProfileDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Info Rows
                      if (user.location != null &&
                          user.location!.isNotEmpty) ...[
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          user.location!,
                        ),
                        if (user.createdAt != null &&
                            user.createdAt!.isNotEmpty)
                          const SizedBox(height: 16),
                      ],

                      if (user.createdAt != null && user.createdAt!.isNotEmpty)
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Joined ${DateFormatter.formatDate(user.createdAt)}',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Small Header Title (Fades in at the end)
        Positioned(
          top: topSafePadding,
          left: 64, // space for avatar
          right: 16,
          height: kToolbarHeight,
          child: Opacity(
            opacity: smallTitleOpacity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // 4. Edit Profile Icon Button (Top Right)
        Positioned(
          top:
              topSafePadding +
              (kToolbarHeight - 48) /
                  2, // Center vertically with the small title
          right: 8,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: IconButton(
              icon: const Icon(Icons.edit_note_outlined, color: Colors.white),
              onPressed: onEditProfile,
            ),
          ),
        ),

        // 5. Floating Avatar
        Positioned(
          left: currentAvatarX,
          top: currentAvatarY,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: currentAvatarSize,
                height: currentAvatarSize,
                padding: EdgeInsets.all(4 * (1 - progress)), // padding shrinks
                decoration: BoxDecoration(
                  color: progress < 0.5
                      ? Colors.white
                      : Colors.transparent, // remove white ring when collapsed
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: currentAvatarSize * 0.5,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              // Online Status Indicator (fades out quickly)
              if (progress < 0.5)
                Positioned(
                  bottom: 6 * (1 - progress),
                  right: 6 * (1 - progress),
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColor.textProfileLight),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColor.textProfileLight,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
