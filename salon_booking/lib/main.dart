import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/services/auth_service.dart';

import 'controllers/admin_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/mock_auth_service.dart';
import 'app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put<AuthService>(MockAuthService(), permanent: true);
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
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      theme: ThemeData(primarySwatch: Colors.pink),
    );
  }
}