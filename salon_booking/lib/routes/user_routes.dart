import 'package:get/get.dart';
import 'package:salon_booking/controllers/booking_controller.dart';
import 'package:salon_booking/views/user/user_review_booking_screen.dart';
import 'package:salon_booking/views/user/user_select_datetime_screen.dart';
import '../views/user/user_main_shell.dart';
import '../bindings/user_binding.dart';
import 'package:salon_booking/views/user/user_appointments_screen.dart';
import 'package:salon_booking/views/user/user_booking_success_screen.dart';
import 'package:salon_booking/views/user/user_explore_screen.dart';
import 'package:salon_booking/views/user/user_payment_screen.dart';
import 'package:salon_booking/views/user/user_profile_screen.dart';
import 'package:salon_booking/views/user/user_rate_experience_screen.dart';
import 'package:salon_booking/views/user/user_salon_details_screen.dart';
import 'package:salon_booking/views/user/user_edit_profile_screen.dart';
import 'package:salon_booking/views/user/user_settings_screen.dart';

class UserRoutes {
  static const userRoot = '/user';

  static const explore = '/user/explore';
  static const salonDetails = '/user/salon-details';

  static const selectDateTime = '/user/booking/datetime';
  static const reviewBooking = '/user/booking/review';
  static const bookingSuccess = '/user/booking/success';

  static const payment = '/user/payment';
  static const myAppointments = '/user/appointments';
  static const rateExperience = '/user/rate-experience';
  static const profile = '/user/profile';
  static const editProfile = '/user/edit-profile';
  static const settings = '/user/settings';
  static const assistant = '/user/assistant';

  static final pages = [
    GetPage(
      name: userRoot,
      page: () => const UserMainShell(),
      binding: UserBinding(),
    ),
    GetPage(name: explore, page: () => const UserExploreScreen()),
    GetPage(name: salonDetails, page: () => const UserSalonDetailsScreen()),
    GetPage(name: selectDateTime, page: () => const UserSelectDateTimeScreen()),
    GetPage(name: reviewBooking, page: () => const UserReviewBookingScreen()),
    GetPage(name: payment, page: () => const UserPaymentScreen()),
    GetPage(name: bookingSuccess, page: () => const UserBookingSuccessScreen()),
    GetPage(name: myAppointments, page: () => UserAppointmentsScreen()),
    GetPage(
      name: '/user/rate-experience',
      page: () => const UserRateExperienceScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<BookingController>()) {
          Get.put(BookingController());
        }
      }),
    ),

    GetPage(name: profile, page: () => const UserProfileScreen()),
    GetPage(name: editProfile, page: () => const UserEditProfileScreen()),
    GetPage(name: settings, page: () => const UserSettingsScreen()),
  ];
}
