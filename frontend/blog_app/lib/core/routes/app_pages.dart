import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/initial_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/views/home_view.dart';
import '../../features/notifications/bindings/notifications_binding.dart';
import '../../features/notifications/views/notifications_view.dart';
import '../../features/post/bindings/post_binding.dart';
import '../../features/post/views/post_view.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/auth/bindings/change_password_binding.dart';
import '../../features/auth/views/change_password_view.dart';
import '../../features/profile/bindings/edit_profile_binding.dart';
import '../../features/profile/views/edit_profile_view.dart';
import '../../features/post/bindings/edit_post_binding.dart';
import '../../features/post/views/edit_post_view.dart';
import '../../features/profile/bindings/my_posts_binding.dart';
import '../../features/profile/views/my_posts_view.dart';
import '../../features/profile/bindings/saved_posts_binding.dart';
import '../../features/profile/views/saved_posts_view.dart';
import '../../features/root/bindings/root_binding.dart';
import '../../features/root/views/root_view.dart';
import '../../features/settings/bindings/settings_binding.dart';
import '../../features/settings/views/settings_view.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.INITIAL;

  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const InitialView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.ROOT,
      page: () => const RootView(),
      binding: RootBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: Routes.POST,
      page: () => const PostView(),
      binding: PostBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.EDIT_POST,
      page: () => const EditPostView(),
      binding: EditPostBinding(),
    ),
    GetPage(
      name: Routes.MY_POSTS,
      page: () => const MyPostsView(),
      binding: MyPostsBinding(),
    ),
    GetPage(
      name: Routes.SAVED_POSTS,
      page: () => const SavedPostsView(),
      binding: SavedPostsBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
  ];
}
