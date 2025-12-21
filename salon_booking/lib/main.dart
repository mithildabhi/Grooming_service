import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'services/auth_service.dart';
import 'services/django_auth_service.dart';

import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 THIS IS THE KEY FIX
  Get.put<AuthService>(DjangoAuthService(), permanent: true);

  Get.put(AuthController(), permanent: true);
  Get.put(AdminController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon Booking App',
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.pink),
    );
  }
}
