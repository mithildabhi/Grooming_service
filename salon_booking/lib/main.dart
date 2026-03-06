import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:salon_booking/controllers/appointment_controller.dart';
import 'package:salon_booking/controllers/auth_controller.dart';
import 'package:salon_booking/controllers/admin_controller.dart'; // ✅ ADD
import 'package:salon_booking/controllers/booking_controller.dart';
import 'package:salon_booking/controllers/salon_controls_controller.dart';
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
  print("==================================================");
  print("🔥 FCM TOKEN: $token");
  print("==================================================");

  // ✅ Foreground Notification Listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔔 Foreground Notification: ${message.notification?.title}");
    
    if (message.notification != null) {
      // 1. Show elegant snackbar inside the app
      Get.snackbar(
        message.notification!.title ?? 'New Notification',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(Icons.notifications_active, color: Colors.blue),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 4),
        isDismissible: true,
        onTap: (_) {
          _handleNotificationClick(message.data);
        },
      );

      // 2. Show in System Tray (Outside the app)
      NotificationService.showLocalNotification(message);
    }
  });

  // ✅ Background/Terminated Notification Tap Listener
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🔔 Notification Clicked: ${message.data}");
    _handleNotificationClick(message.data);
  });



  // ✅ Initialize ALL controllers at startup
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(BookingController(), permanent: true);
  Get.put(AppointmentController(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(AdminController(), permanent: true);
  Get.put(SalonControlsController(), permanent: true);
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

// ✅ Shared Notification Click Handler
void _handleNotificationClick(Map<String, dynamic> data) {
  print("🎯 Handling notification click: $data");
  
  try {
    if (Get.find<AuthController>().isLoggedIn.value) {
      if (Get.find<AuthController>().role.value == 'admin') {
         // Navigate to Admin bookings tab (index 1)
         Get.offAllNamed('/admin', arguments: {'tab': 1});
      } else {
         // Navigate to User bookings tab (index 3)
         Get.offAllNamed(AppRoutes.userHome, arguments: {'tab': 3});
      }
    }
  } catch (e) {
    print("❌ Error handling notification click: $e");
  }
}
