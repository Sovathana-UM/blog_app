import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/edit_profile_view.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileMenu({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline, 'Edit Profile', onTap: () {
          Get.to(() => const EditProfileView());
        }),
        _buildMenuItem(Icons.article_outlined, 'My Posts'),
        _buildMenuItem(Icons.bookmark_border, 'Saved Posts'),
        _buildMenuItem(Icons.notifications_none, 'Notification Settings'),
        _buildMenuItem(Icons.lock_outline, 'Change Password'),
        _buildMenuItem(Icons.dark_mode_outlined, 'Dark Mode'),
        _buildMenuItem(Icons.language, 'Language'),
        _buildMenuItem(Icons.help_outline, 'Help & Support'),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          onTap: onLogout,
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
