import 'package:flutter/material.dart';

import 'package:blog_app/core/theme/app_color.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final List<Widget> withDividers = [];
    for (int i = 0; i < children.length; i++) {
      withDividers.add(children[i]);
      if (i < children.length - 1) {
        withDividers.add(
          const Divider(height: 1, indent: 64, color: AppColor.borderLight),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: withDividers),
    );
  }
}
