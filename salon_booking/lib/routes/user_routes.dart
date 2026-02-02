import 'package:get/get.dart';
import 'package:salon_booking/views/user/user_my_reviews_screen.dart';

import '../bindings/user_binding.dart';

import '../views/user/user_main_shell.dart';
import '../views/user/user_salon_details_screen.dart';
import '../views/user/user_select_datetime_screen.dart';
import '../views/user/user_review_booking_screen.dart';
import '../views/user/user_payment_screen.dart';
import '../views/user/user_booking_success_screen.dart';
import '../views/user/user_appointment_details_screen.dart';
import '../views/user/user_rate_experience_screen.dart';
import '../views/user/user_edit_profile_screen.dart';
import '../views/user/user_settings_screen.dart';

class UserRoutes {
  static const userHome = '/user';

  static final List<GetPage> routes = [
    GetPage(
      name: userHome,
      page: () => const UserMainShell(),
      binding: UserBinding(),
    ),

    GetPage(
      name: '/salon-details',
      page: () => const UserSalonDetailsScreen(),
    ),

    GetPage(
      name: '/select-datetime',
      page: () => const UserSelectDateTimeScreen(),
    ),

    GetPage(
      name: '/review-booking',
      page: () => const UserReviewBookingScreen(),
    ),

    GetPage(
      name: '/payment',
      page: () => const UserPaymentScreen(),
    ),

    GetPage(
      name: '/booking-success',
      page: () => const UserBookingSuccessScreen(),
    ),

    GetPage(
      name: '/appointment-details',
      page: () => const UserAppointmentDetailsScreen(),
    ),
  GetPage(
    name: '/my-reviews',
    page: () => const UserMyReviewsScreen(),
  ),
    GetPage(
      name: '/rate-experience',
      page: () => const UserRateExperienceScreen(),
    ),

    GetPage(
      name: '/edit-profile',
      page: () => const UserEditProfileScreen(),
    ),

    GetPage(
      name: '/settings',
      page: () => const UserSettingsScreen(),
    ),
  ];

  /// ✅ REQUIRED for main.dart spread operator
  static List<GetPage> get pages => routes;
}

