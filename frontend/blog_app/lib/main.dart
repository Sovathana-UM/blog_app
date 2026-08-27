import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/routes/app_pages.dart';
import 'firebase_options.dart';
import 'core/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await LocalNotificationService.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  Get.put(ThemeService(prefs));

  runApp(
    GetMaterialApp(
      title: "Blogify",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeService>().theme,
    ),
  );
}
