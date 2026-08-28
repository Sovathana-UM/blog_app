import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/app_routes.dart';
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
        _buildMenuItem(Icons.article_outlined, 'My Posts', onTap: () {
          Get.toNamed(Routes.MY_POSTS);
        }),
        _buildMenuItem(Icons.bookmark_border, 'Saved Posts', onTap: () {
          Get.toNamed(Routes.SAVED_POSTS);
        }),
        _buildMenuItem(Icons.lock_outline, 'Change Password', onTap: () {
          Get.toNamed(Routes.CHANGE_PASSWORD);
        }),

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
