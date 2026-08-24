import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  // Login Observables
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final isLoginLoading = false.obs;
  final isLoginPasswordObscured = true.obs;

  // Register Observables
  final regFirstNameController = TextEditingController();
  final regLastNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();
  final isRegLoading = false.obs;
  final isRegPasswordObscured = true.obs;

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
        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint('AuthController: Token invalid. Clearing storage and routing to LOGIN.');
        // Token invalid, clear it
        await prefs.remove('auth_token');
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      debugPrint('AuthController: No token found. Routing to LOGIN.');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> login() async {
    debugPrint('AuthController: login() called.');
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
      debugPrint('AuthController: Validation failed. Empty fields.');
      Get.snackbar('Error', 'Please fill in all fields', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoginLoading.value = true;
    try {
      final response = await _authProvider.login(loginEmailController.text, loginPasswordController.text);
      if (response['success'] == true) {
        debugPrint('AuthController: Login successful. Payload: $response');
        // Save Token
        final token = response['data']['token'];
        if (token == null) {
            debugPrint('AuthController: ERROR - Token is null in response!');
            Get.snackbar('Error', 'Server did not return a token', backgroundColor: Colors.redAccent, colorText: Colors.white);
            return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Fetch User Info
        currentUser.value = await _authProvider.getCurrentUser();

        Get.snackbar('Success', 'Welcome Back!', backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint('AuthController: Login failed from API: ${response['message']}');
        Get.snackbar('Error', response['message'] ?? 'Login failed', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('AuthController: Caught exception in login: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register() async {
    debugPrint('AuthController: register() called.');
    if (regFirstNameController.text.isEmpty || regEmailController.text.isEmpty || regPasswordController.text.isEmpty) {
      debugPrint('AuthController: Validation failed. Empty fields.');
      Get.snackbar('Error', 'Please fill in all required fields', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (regPasswordController.text != regConfirmPasswordController.text) {
      debugPrint('AuthController: Validation failed. Passwords do not match.');
      Get.snackbar('Error', 'Passwords do not match', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

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
        debugPrint('AuthController: Registration successful. Payload: $response');
        // Save Token
        final token = response['data']['token'];
        if (token == null) {
            debugPrint('AuthController: ERROR - Token is null in response!');
            Get.snackbar('Error', 'Server did not return a token', backgroundColor: Colors.redAccent, colorText: Colors.white);
            return;
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Fetch User Info
        currentUser.value = await _authProvider.getCurrentUser();

        Get.snackbar('Success', 'Account created successfully!', backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(Routes.ROOT);
      } else {
        debugPrint('AuthController: Registration failed from API: ${response['message']}');
        Get.snackbar('Error', response['message'] ?? 'Registration failed', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('AuthController: Caught exception in register: $e');
      Get.snackbar('Error', 'Something went wrong', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isRegLoading.value = false;
    }
  }

  Future<void> logout() async {
    debugPrint('AuthController: logout() called.');
    try {
      await _authProvider.logout();
    } catch (e) {
      debugPrint('AuthController: Ignored error during API logout: $e');
      // Ignore error if already logged out on server
    } finally {
      debugPrint('AuthController: Clearing local storage and routing to LOGIN.');
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
}
