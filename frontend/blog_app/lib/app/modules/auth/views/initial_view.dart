import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class InitialView extends GetView<AuthController> {
  const InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is injected with permanent:true and checks auth status onInit.
    // So we just show a spinner here until it decides where to route.
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2E6FF2),
        ),
      ),
    );
  }
}
