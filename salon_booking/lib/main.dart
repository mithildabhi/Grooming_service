import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:salon_booking/controllers/appointment_controller.dart';
import 'package:salon_booking/controllers/auth_controller.dart';
import 'package:salon_booking/controllers/admin_controller.dart'; // ✅ ADD
import 'package:salon_booking/controllers/booking_controller.dart';
import 'package:salon_booking/controllers/location_controller.dart';
import 'package:salon_booking/controllers/user_controller.dart'; // ✅ ADD THIS
import 'package:salon_booking/services/auth_service.dart';
import 'package:salon_booking/services/notification_service.dart';
import 'package:salon_booking/views/splash_screen.dart';
import 'package:salon_booking/routes/app_routes.dart';
import 'package:salon_booking/routes/admin_routes.dart';
import 'package:salon_booking/routes/user_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Notification Service
  await NotificationService.init();
  String? token = await NotificationService.getToken();
  print("FCM TOKEN = $token");


  // ✅ Initialize ALL controllers at startup
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(BookingController(), permanent: true);
  Get.put(AppointmentController(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(AdminController(), permanent: true);
  Get.put(LocationController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
