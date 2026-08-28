import 'package:blog_app/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Sign up to get started',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              _buildTextField(
                'First Name',
                'Enter your first name',
                controller.regFirstNameController,
                Icons.person_outline,
                errorKey: 'first_name',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Last Name',
                'Enter your last name',
                controller.regLastNameController,
                Icons.person_outline,
                errorKey: 'last_name',
              ),
              const SizedBox(height: 20),

              _buildTextField(
                'Email Address',
                'Enter your email',
                controller.regEmailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                errorKey: 'email',
              ),
              const SizedBox(height: 20),

              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: controller.regPasswordController,
                  obscureText: controller.isRegPasswordObscured.value,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textHint,
                    ),
                    errorText: controller.regErrors.containsKey('password')
                        ? controller.regErrors['password']
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isRegPasswordObscured.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.textHint,
                      ),
                      onPressed: controller.toggleRegPasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: controller.regConfirmPasswordController,
                  obscureText: controller
                      .isRegPasswordObscured
                      .value, // Shared visibility for simplicity
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.textHint,
                    ),
                    errorText:
                        controller.regErrors.containsKey(
                          'password_confirmation',
                        )
                        ? controller.regErrors['password_confirmation']
                        : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isRegPasswordObscured.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.textHint,
                      ),
                      onPressed: controller.toggleRegPasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.primary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isRegLoading.value
                      ? null
                      : controller.register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isRegLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController txtController,
    IconData icon, {
    TextInputType? keyboardType,
    String? errorKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: txtController,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColor.textHint,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColor.textHint),
              errorText:
                  errorKey != null && controller.regErrors.containsKey(errorKey)
                  ? controller.regErrors[errorKey]
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.primary),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            keyboardType: keyboardType,
          ),
        ),
      ],
    );
  }
}
