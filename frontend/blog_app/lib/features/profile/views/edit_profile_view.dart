import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/edit_profile_controller.dart';
import '../../auth/controller/auth_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSubmitting.value ? null : controller.submit,
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildAvatarPicker(),
            const SizedBox(height: 32),
            _buildTextField('First Name', controller.firstNameController),
            const SizedBox(height: 16),
            _buildTextField('Last Name', controller.lastNameController),
            const SizedBox(height: 16),
            _buildTextField('Bio', controller.bioController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Location', controller.locationController),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: controller.pickAvatar,
      child: Stack(
        children: [
          Obx(() {
            final selectedAvatar = controller.selectedAvatar.value;
            final currentUser = Get.find<AuthController>().currentUser.value;

            ImageProvider? imageProvider;
            if (selectedAvatar != null) {
              imageProvider = FileImage(selectedAvatar);
            } else if (currentUser?.avatarUrl != null) {
              imageProvider = NetworkImage(currentUser!.avatarUrl!);
            }

            return CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                  : null,
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2E6FF2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
