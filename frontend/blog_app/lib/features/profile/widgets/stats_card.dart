import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final int totalPosts;
  final int followers;
  final int following;

  const StatsCard({
    super.key,
    required this.totalPosts,
    this.followers = 0,
    this.following = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Posts', totalPosts),
          _buildStatItem('Followers', followers),
          _buildStatItem('Following', following),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }
}
