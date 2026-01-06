import 'package:get/get.dart';
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

class UserRoutes {
  static const String userRoot = '/user';
  static const explore = '/user/explore';
  static const salonDetails = '/user/salon';
  static const serviceDetails = '/user/service';
  static const selectDateTime = '/user/select-time';
  static const reviewBooking = '/user/review-booking';
  static const payment = '/user/payment';
  static const bookingSuccess = '/user/success';
  static const myAppointments = '/user/appointments';
  static const rateExperience = '/user/rate';
  static const profile = '/user/profile';
  static const assistant = '/user/assistant';

  static final pages = [
  GetPage(
      name: userRoot,
      page: () => const UserMainShell(),
      binding: UserBinding(),
    ),
    GetPage(name: '/user/explore', page: () => const UserExploreScreen()),
    GetPage(name: '/user/salon-details', page: () => const UserSalonDetailsScreen()),
    GetPage(name: '/user/payment', page: () => const UserPaymentScreen()),
    GetPage(name: '/user/booking-success', page: () => const UserBookingSuccessScreen()),
    GetPage(name: '/user/appointments', page: () =>  UserAppointmentsScreen()),
    GetPage(name: '/user/rate-experience', page: () => const UserRateExperienceScreen()),
    GetPage(name: '/user/profile', page: () => const UserProfileScreen()),
    // Booking Flow Routes
    GetPage(
      name: '/user/booking/datetime',
      page: () => const UserSelectDateTimeScreen(),
    ),
    GetPage(
      name: '/user/booking/review',
      page: () => const UserReviewBookingScreen(),
    ),
    GetPage(
      name: '/user/booking/success',
      page: () => const UserBookingSuccessScreen(),
    ),
  ];

  static List<GetPage> get routes => pages; 
}
