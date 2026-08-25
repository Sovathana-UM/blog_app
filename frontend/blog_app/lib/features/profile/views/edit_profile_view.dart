import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controller/auth_controller.dart';

class EditProfileView extends GetView<AuthController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final bioController = TextEditingController(text: user.bio);
    final locationController = TextEditingController(text: user.location);
    final genderController = TextEditingController(text: user.gender);
    final dobController = TextEditingController(text: user.dateOfBirth);

    final isSaving = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(() => TextButton(
            onPressed: isSaving.value
                ? null
                : () async {
                    isSaving.value = true;
                    final success = await controller.updateProfile({
                      'first_name': firstNameController.text.trim(),
                      'last_name': lastNameController.text.trim(),
                      'bio': bioController.text.trim(),
                      'location': locationController.text.trim(),
                      'gender': genderController.text.trim(),
                      'date_of_birth': dobController.text.trim(),
                    });
                    isSaving.value = false;
                    if (success) {
                      Get.back();
                      Get.snackbar('Success', 'Profile updated', backgroundColor: Colors.green, colorText: Colors.white);
                    } else {
                      Get.snackbar('Error', 'Failed to update profile', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    }
                  },
            child: isSaving.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
