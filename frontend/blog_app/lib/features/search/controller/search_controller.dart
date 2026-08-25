import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../features/post/models/post_model.dart';
import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

class SearchController extends GetxController {
  final DioClient _dioClient = DioClient();
  
  final searchController = TextEditingController();
  final RxList<PostModel> searchResults = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    isLoading.value = true;
    hasSearched.value = true;
    
    try {
      final response = await _dioClient.dio.get('/search/posts', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        searchResults.assignAll(data.map((e) => PostModel.fromJson(e)).toList());
      }
    } on DioException catch (e) {
      debugPrint('Search error: $e');
      Get.snackbar('Error', 'Failed to search posts', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
