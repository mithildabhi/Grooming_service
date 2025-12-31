import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salon_booking/theme/ai_admin_theme.dart';
import 'package:salon_booking/theme/auth_theme.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'controllers/auth_controller.dart';
import 'routes/app_routes.dart';
import 'routes/user_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // DEPENDENCY INJECTION
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  // Get.put<AdminController>(AdminController(), permanent: true);  Temporarily disabled

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon Booking App',
      // ROUTING
      initialRoute: AppRoutes.splash,
      getPages: [
        ...AppRoutes.routes,
        ...UserRoutes.pages, 
      ],
      // 🌤 USER / AUTH THEME (DEFAULT)
      theme: AuthTheme.theme,

      // 🌑 ADMIN THEME
      darkTheme: AIAdminTheme.theme,

      // IMPORTANT: Let GetX control theme switching
      themeMode: ThemeMode.light,
    );
  }
}
