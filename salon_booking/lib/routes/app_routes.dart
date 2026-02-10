import 'package:get/get.dart';
import 'package:salon_booking/views/admin/admin_shell.dart';
import 'package:salon_booking/views/splash_screen.dart';
import 'package:salon_booking/views/login_screen.dart';
import 'package:salon_booking/views/register_screen.dart';
import 'package:salon_booking/views/user/user_main_shell.dart';
import 'package:salon_booking/bindings/user_binding.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const adminDashboard = '/admin-dashboard';
  static const userHome = '/user';

  static final List<GetPage> routes = <GetPage>[
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    // ✅ Remove binding - AdminController already exists
    GetPage(name: adminDashboard, page: () => const AdminShell()),
    // ✅ User home route with binding
    GetPage(
      name: userHome,
      page: () => const UserMainShell(),
      binding: UserBinding(),
    ),
  ];
}
