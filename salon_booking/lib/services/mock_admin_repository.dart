import 'admin_repository.dart';

class MockAdminRepository implements AdminRepository {
  final String _salonId = 'mock_salon_1';

  final List<Map<String, dynamic>> _staff = [
    {'id': '1', 'name': 'Amit', 'role': 'Stylist'},
  ];

  final List<Map<String, dynamic>> _services = [
    {'id': '1', 'name': 'Haircut', 'price': 200},
  ];

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '1',
      'service': 'Haircut',
      'status': 'approved',
      'startAt': DateTime.now(),
      'price': 200,
    },
  ];

  @override
  Future<String> getOrCreateSalon() async => _salonId;

  @override
  Future<Map<String, dynamic>> getSalonProfile(String salonId) async {
    return {'name': 'My Salon', 'phone': '0000000000'};
  }

  @override
  Future<List<Map<String, dynamic>>> getStaff(String salonId) async => _staff;

  @override
  Future<List<Map<String, dynamic>>> getServices(String salonId) async =>
      _services;

  @override
  Future<List<Map<String, dynamic>>> getBookings(String salonId) async =>
      _bookings;

  @override
  Future<List<Map<String, dynamic>>> getReviews(String salonId) async => [];

  @override
  Future<void> addBooking(Map<String, dynamic> booking) async {
    _bookings.add(booking);
  }

  @override
  Future<void> updateBooking(String id, Map<String, dynamic> data) async {
    final i = _bookings.indexWhere((e) => e['id'] == id);
    if (i != -1) _bookings[i].addAll(data);
  }
}
