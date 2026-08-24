import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/post_controller.dart';

class PostView extends GetView<PostController> {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Create Post Content'),
      ),
    );
  }
}
