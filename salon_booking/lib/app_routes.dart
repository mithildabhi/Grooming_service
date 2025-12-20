// lib/app_routes.dart
import 'package:get/get.dart';
import 'package:salon_booking/views/splash_screen.dart';
import 'package:salon_booking/views/login_screen.dart';
import 'package:salon_booking/views/register_screen.dart';

import 'package:salon_booking/views/admin/admin_home_screen.dart';
import 'package:salon_booking/views/admin/admin_bookings_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/reviews_screen.dart';
import 'package:salon_booking/views/admin/profile_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';
import 'package:salon_booking/views/admin/offers_screen.dart';
import 'package:salon_booking/views/admin/inventory_screen.dart';
import 'package:salon_booking/views/admin/gallery_screen.dart';

import 'package:salon_booking/views/user/home_screen.dart';
import 'package:salon_booking/views/user/booking_form.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  static const adminDashboard = '/admin-dashboard';
  static const adminBookings = '/admin-bookings';
  static const adminServices = '/admin-services';
  static const adminEmployees = '/admin-employees';
  static const adminReviews = '/admin-reviews';
  static const adminProfile = '/admin-profile';
  static const adminSettings = '/admin-settings';
  static const adminOffers = '/admin-offers';
  static const adminInventory = '/admin-inventory';
  static const adminGallery = '/admin-gallery';

  static const userHome = '/user-home';
  static const userBooking = '/user-booking-form';

  static final List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),

    // ✅ ADMIN ROOT (BOTTOM NAV)
    GetPage(name: adminDashboard, page: () => const AdminHomeScreen()),

    // ✅ ADMIN SUB SCREENS
    GetPage(
      name: adminBookings,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final salonId = args?['salonId'] ?? '';
        return AdminBookingsScreen(salonId: salonId);
      },
    ),
    GetPage(name: adminServices, page: () => const ServicesScreen()),
    GetPage(name: adminEmployees, page: () => EmployeesScreen()),
    GetPage(name: adminReviews, page: () => const ReviewsScreen()),
    GetPage(name: adminProfile, page: () => const ProfileScreen()),
    GetPage(name: adminSettings, page: () => const SettingsScreen()),
    GetPage(name: adminOffers, page: () => const OffersScreen()),
    GetPage(name: adminInventory, page: () => const InventoryScreen()),
    GetPage(name: adminGallery, page: () => const GalleryScreen()),

    // ✅ USER
    GetPage(name: userHome, page: () => const UserHomeScreen()),
    GetPage(name: userBooking, page: () => const BookingForm()),
  ];
}
