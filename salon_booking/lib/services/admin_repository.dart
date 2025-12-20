abstract class AdminRepository {
  Future<String> getOrCreateSalon();
  Future<Map<String, dynamic>> getSalonProfile(String salonId);

  Future<List<Map<String, dynamic>>> getStaff(String salonId);
  Future<List<Map<String, dynamic>>> getServices(String salonId);
  Future<List<Map<String, dynamic>>> getBookings(String salonId);
  Future<List<Map<String, dynamic>>> getReviews(String salonId);

  Future<void> addBooking(Map<String, dynamic> booking);
  Future<void> updateBooking(String id, Map<String, dynamic> data);
}
