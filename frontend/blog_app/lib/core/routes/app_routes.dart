abstract class Routes {
  Routes._();
  static const INITIAL = _Paths.INITIAL;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const ROOT = _Paths.ROOT;
  static const HOME = _Paths.HOME;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const POST = _Paths.POST;
  static const SETTINGS = _Paths.SETTINGS;
  static const PROFILE = _Paths.PROFILE;
  static const EDIT_PROFILE = _Paths.EDIT_PROFILE;
  static const EDIT_POST = _Paths.EDIT_POST;
  static const MY_POSTS = _Paths.MY_POSTS;
  static const SAVED_POSTS = _Paths.SAVED_POSTS;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
}

abstract class _Paths {
  _Paths._();
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const ROOT = '/root';
  static const HOME = '/home';
  static const NOTIFICATIONS = '/notifications';
  static const POST = '/post';
  static const SETTINGS = '/settings';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/edit-profile';
  static const EDIT_POST = '/edit-post';
  static const MY_POSTS = '/my-posts';
  static const SAVED_POSTS = '/saved-posts';
  static const CHANGE_PASSWORD = '/change-password';
}
