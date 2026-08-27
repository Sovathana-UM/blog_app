import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/edit_post_controller.dart';

class EditPostView extends GetView<EditPostController> {
  const EditPostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      controller.submitEdit();
                    },
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: controller.contentController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display existing images (read-only for now)
                  if (controller.post.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                controller.post.imageUrls[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
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
}
