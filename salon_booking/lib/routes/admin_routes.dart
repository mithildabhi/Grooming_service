import 'package:get/get.dart';
import 'package:salon_booking/views/admin/admin_shell.dart';
import 'package:salon_booking/views/admin/admin_bookings_screen.dart';
import 'package:salon_booking/views/admin/services_screen.dart';
import 'package:salon_booking/views/admin/employee_screen.dart';
import 'package:salon_booking/views/admin/reviews_screen.dart';
import 'package:salon_booking/views/admin/profile_screen.dart';
import 'package:salon_booking/views/admin/settings_screen.dart';
import 'package:salon_booking/views/admin/offers_screen.dart';
import 'package:salon_booking/views/admin/inventory_screen.dart';
import 'package:salon_booking/views/admin/gallery_screen.dart';
import 'package:salon_booking/views/admin/edit_profile_screen.dart';

class AdminRoutes {
  static const adminDashboard = '/admin';
  static const bookings = '/admin/bookings';
  static const services = '/admin/services';
  static const employees = '/admin/employees';
  static const reviews = '/admin/reviews';
  static const profile = '/admin/profile';
  static const editProfile = '/admin/edit-profile';
  static const settings = '/admin/settings';
  static const offers = '/admin/offers';
  static const inventory = '/admin/inventory';
  static const gallery = '/admin/gallery';

  static final pages = [
    // ✅ No binding needed - AdminController already initialized
    GetPage(
      name: adminDashboard,
      page: () => const AdminShell(),
    ),

    GetPage(
      name: bookings,
      page: () {
        return AdminBookingsScreen();
      },
    ),

    GetPage(name: services, page: () => const ServicesScreen()),
    GetPage(name: employees, page: () => const EmployeeScreen()),
    GetPage(name: reviews, page: () => const ReviewsScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: editProfile, page: () => EditProfileScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: offers, page: () => const OffersScreen()),
    GetPage(name: inventory, page: () => const InventoryScreen()),
    GetPage(name: gallery, page: () => const GalleryScreen()),
  ];
}