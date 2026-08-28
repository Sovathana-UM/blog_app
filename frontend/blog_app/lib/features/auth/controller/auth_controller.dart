import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/auth/repository/auth_repository.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authProvider = AuthRepository();

  // Login Observables
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginLoading = false.obs;
  final isLoginPasswordObscured = true.obs;
  final loginErrors = <String, String>{}.obs;

  // Register Observables
  final regFirstNameController = TextEditingController();
  final regLastNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  final isRegLoading = false.obs;
  final isRegPasswordObscured = true.obs;
  final regErrors = <String, String>{}.obs;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordObscured.value = !isLoginPasswordObscured.value;
  }

  void toggleRegPasswordVisibility() {
    isRegPasswordObscured.value = !isRegPasswordObscured.value;
  }

  Future<void> checkAuthStatus() async {
    debugPrint('AuthController: Checking auth status...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      debugPrint('AuthController: Token found in local storage.');
      // Try to fetch current user to verify token is still valid
      final user = await _authProvider.getCurrentUser();
      if (user != null) {
        debugPrint('AuthController: User is authenticated. Routing to ROOT.');
        currentUser.value = user;
        await setupPushNotifications();
        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint(
          'AuthController: Token invalid. Clearing storage and routing to LOGIN.',
        );
        // Token invalid, clear it
        await prefs.remove('auth_token');
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      debugPrint('AuthController: No token found. Routing to LOGIN.');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        if (token != null) {
          debugPrint('FCM Token: $token');
          // Assuming updateFcmToken exists in the AuthRepository or logic
          await _authProvider.updateFcmToken(token);
        }
      }
    } catch (e) {
      debugPrint('Error setting up push notifications: $e');
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      final user = await _authProvider.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      debugPrint('AuthController: Error refreshing user: $e');
    }
  }

  Future<void> login() async {
    debugPrint('AuthController: login() called.');
    if (loginEmailController.text.isEmpty ||
        loginPasswordController.text.isEmpty) {
      loginErrors.clear();
      if (loginEmailController.text.isEmpty)
        loginErrors['email'] = 'Email is required';
      if (loginPasswordController.text.isEmpty)
        loginErrors['password'] = 'Password is required';
      return;
    }

    loginErrors.clear();
    isLoginLoading.value = true;
    try {
      final response = await _authProvider.login(
        loginEmailController.text,
        loginPasswordController.text,
      );
      if (response['success'] == true) {
        debugPrint('AuthController: Login successful. Payload: $response');
        // Save Token
        final token = response['data']['token'];
        if (token == null) {
          loginErrors['general'] = 'Server did not return a token';
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Fetch User Info
        currentUser.value = await _authProvider.getCurrentUser();
        await setupPushNotifications();

        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint(
          'AuthController: Login failed from API: ${response['message']}',
        );
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              loginErrors[key] = value[0].toString();
            }
          });
        } else {
          loginErrors['email'] = response['message'] ?? 'Login failed';
        }
      }
    } catch (e) {
      loginErrors['general'] = e.toString();
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    debugPrint('AuthController: register() called.');
    if (regFirstNameController.text.isEmpty ||
        regLastNameController.text.isEmpty ||
        regEmailController.text.isEmpty ||
        regPasswordController.text.isEmpty) {
      regErrors.clear();
      if (regFirstNameController.text.isEmpty)
        regErrors['first_name'] = 'First name is required';
      if (regLastNameController.text.isEmpty)
        regErrors['last_name'] = 'Last name is required';
      if (regEmailController.text.isEmpty)
        regErrors['email'] = 'Email is required';
      if (regPasswordController.text.isEmpty)
        regErrors['password'] = 'Password is required';
      return;
    }

    if (regPasswordController.text != regConfirmPasswordController.text) {
      debugPrint('AuthController: Validation failed. Passwords do not match.');
      regErrors.clear();
      regErrors['password_confirmation'] = 'Passwords do not match';
      return;
    }

    regErrors.clear();
    isRegLoading.value = true;
    try {
      final response = await _authProvider.register(
        regFirstNameController.text,
        regLastNameController.text,
        regEmailController.text,
        regPasswordController.text,
        regConfirmPasswordController.text,
      );

      if (response['success'] == true) {
        debugPrint(
          'AuthController: Registration successful. Payload: $response',
        );
        // Save Token
        final token = response['data']['token'];
        if (token == null) {
          debugPrint('AuthController: ERROR - Token is null in response!');
          regErrors['general'] = 'Server did not return a token';
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Fetch User Info
        currentUser.value = await _authProvider.getCurrentUser();
        await setupPushNotifications();

        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint(
          'AuthController: Registration failed from API: ${response['message']}',
        );
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              regErrors[key] = value[0].toString();
            }
          });
        } else {
          regErrors['email'] = response['message'] ?? 'Registration failed';
        }
      }
    } catch (e) {
      debugPrint('AuthController: Caught exception in register: $e');
      regErrors['general'] = 'Something went wrong';
    } finally {
      isRegLoading.value = false;
    }
  }

  Future<void> logout() async {
    debugPrint('AuthController: logout() called.');
    try {
      await _authProvider.removeFcmToken();
      await _authProvider.logout();
    } catch (e) {
      debugPrint('AuthController: Ignored error during API logout: $e');
      // Ignore error if already logged out on server
    } finally {
      debugPrint(
        'AuthController: Clearing local storage and routing to LOGIN.',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      currentUser.value = null;
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    regFirstNameController.dispose();
    regLastNameController.dispose();
    regEmailController.dispose();
    regPasswordController.dispose();
    regConfirmPasswordController.dispose();
    super.onClose();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _authProvider.updateProfile(data);
      if (res['success'] == true) {
        await refreshCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  Future<bool> changePassword(
    String current,
    String newPass,
    String confirmPass,
  ) async {
    try {
      final res = await _authProvider.changePassword(
        current,
        newPass,
        confirmPass,
      );
      return res['success'] == true;
    } catch (e) {
      debugPrint('Change password error: $e');
      return false;
    }
  }

  Future<bool> uploadAvatar(String imagePath) async {
    try {
      final res = await _authProvider.uploadAvatar(imagePath);
      if (res['success'] == true) {
        await refreshCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Upload avatar error: $e');
      return false;
    }
  }
}
