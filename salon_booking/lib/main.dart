import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salon_booking/controllers/auth_controller.dart';
import 'package:salon_booking/controllers/admin_controller.dart';  // ✅ ADD
import 'package:salon_booking/controllers/user_controller.dart';  // ✅ ADD THIS
import 'package:salon_booking/services/auth_service.dart';
import 'package:salon_booking/views/splash_screen.dart';
import 'package:salon_booking/routes/app_routes.dart';
import 'package:salon_booking/routes/admin_routes.dart';
import 'package:salon_booking/routes/user_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // ✅ Initialize ALL controllers at startup
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(AdminController(), permanent: true);  // ✅ ADD THIS
  Get.put(UserController(), permanent: true);  // ✅ ADD THIS

  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StyleX',
      debugShowCheckedModeBanner: false,
      
      home: const SplashScreen(),
      
      getPages: [
        ...AppRoutes.routes,
        ...AdminRoutes.pages,
        ...UserRoutes.pages,
      ],
      
      initialRoute: null,
    );
  }
}