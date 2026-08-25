import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../repository/comment_repository.dart';

class CommentController extends GetxController {
  final CommentRepository _repository = CommentRepository();
  
  final textController = TextEditingController();
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> fetchComments(String postId) async {
    isLoading.value = true;
    try {
      final data = await _repository.getComments(postId);
      comments.assignAll(data);
    } catch (e) {
      debugPrint('CommentController fetchComments error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return false;

    isSubmitting.value = true;
    try {
      final success = await _repository.addComment(postId, text.trim());
      if (success) {
        await fetchComments(postId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CommentController addComment error: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
