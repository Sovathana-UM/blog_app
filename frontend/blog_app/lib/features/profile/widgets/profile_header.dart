import 'package:flutter/material.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/utils/date_formatter.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.grey[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
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
                      user.email,
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (user.location != null && user.location!.isNotEmpty)
                _buildInfoChip(Icons.location_on_outlined, user.location!),
              
              if (user.gender != null && user.gender!.isNotEmpty)
                _buildInfoChip(
                  user.gender!.toLowerCase() == 'female' ? Icons.female : Icons.male, 
                  user.gender!
                ),

              if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty)
                _buildInfoChip(Icons.cake_outlined, DateFormatter.formatDate(user.dateOfBirth)),

              if (user.createdAt != null && user.createdAt!.isNotEmpty)
                _buildInfoChip(Icons.calendar_today_outlined, 'Joined ${DateFormatter.formatDate(user.createdAt)}'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
}
