import 'auth_service.dart';

class MockAuthService implements AuthService {
  bool _loggedIn = false;
  String _role = 'admin'; // change to 'user' if needed

  @override
  Future<void> login(String email, String password) async {
    _loggedIn = true;

    // Simple role logic
    if (email.contains('admin')) {
      _role = 'admin';
    } else {
      _role = 'user';
    }
  }

  @override
  Future<void> register(String email, String password, String role) async {
    _loggedIn = true;
    _role = role;
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  bool isLoggedIn() => _loggedIn;

  @override
  String getRole() => _role;
}
