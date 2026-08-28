import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/theme/app_color.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = user.avatarUrl;
    final String username = user.email.contains('@')
        ? '@${user.email.split('@')[0]}'
        : '@user.email';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Stack(
        children: [
          // Blue Gradient Background
          Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.gradientStart, AppColor.gradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // White Card Content
          Container(
            margin: const EdgeInsets.only(top: 100),
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

                  // Username / Email
                  Text(
                    username,
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
                  if (user.location != null && user.location!.isNotEmpty)
                    _buildInfoRow(Icons.location_on_outlined, user.location!),

                  if (user.createdAt != null && user.createdAt!.isNotEmpty)
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      'Joined ${DateFormatter.formatDate(user.createdAt)}',
                    ),

                  const SizedBox(height: 24),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: onEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      minimumSize: const Size(200, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar overlapping the boundary
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  // Camera Icon
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
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
      ),
    );
  }
}
