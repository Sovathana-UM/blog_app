import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/post_controller.dart';

class PostView extends GetView<PostController> {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSubmitting.value ? null : controller.submitPost,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Post',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                border: InputBorder.none,
              ),
              maxLines: null,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            
            // Image Picker Area
            Obx(() {
              if (controller.selectedImage.value != null) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        controller.selectedImage.value!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: controller.clearImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              return GestureDetector(
                onTap: controller.pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Add a photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Required',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
