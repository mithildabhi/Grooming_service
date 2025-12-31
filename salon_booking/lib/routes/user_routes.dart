import 'package:get/get.dart';
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
    GetPage(name: '/user/appointments', page: () => const UserAppointmentsScreen()),
    GetPage(name: '/user/rate-experience', page: () => const UserRateExperienceScreen()),
    GetPage(name: '/user/profile', page: () => const UserProfileScreen()),
  ];

  static List<GetPage> get routes => pages; 
}
