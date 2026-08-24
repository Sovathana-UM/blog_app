import 'package:get/get.dart';

class RootController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    // The middle button (index 2) is for Add Post, handled separately by the FAB
    if (index != 2) {
      currentIndex.value = index;
    }
  }
}
