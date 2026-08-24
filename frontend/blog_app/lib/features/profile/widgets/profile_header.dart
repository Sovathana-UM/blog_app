import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/network/dio_client.dart';

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
    // We construct the full image URL if it exists
    final String baseUrl = DioClient().dio.options.baseUrl.replaceAll('/api', '');
    final String? avatarUrl = user.profilePicture != null ? '$baseUrl/storage/${user.profilePicture}' : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.firstName.toLowerCase()}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onEditProfile,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.bio!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              if (user.location != null && user.location!.isNotEmpty) ...[
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  user.location!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Joined 2024', // Mocked since we don't fetch created_at currently
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }
}
