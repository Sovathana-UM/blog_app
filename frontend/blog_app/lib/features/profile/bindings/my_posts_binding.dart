import 'package:get/get.dart';
import '../controller/my_posts_controller.dart';

class MyPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPostsController>(() => MyPostsController());
  }
}
