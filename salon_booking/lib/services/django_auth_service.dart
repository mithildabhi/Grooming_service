import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DjangoAuthService implements AuthService {
  static const String baseUrl = 'http://192.168.64.16:8000';

  String? _accessToken;
  String _role = 'user';

  @override
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login/"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": email, // Django uses username
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _accessToken = data['access'];

      // 🔴 TEMP ROLE LOGIC (SAFE DEFAULT)
      // Later we’ll decode JWT or call /me/
      _role = email == 'admin' ? 'admin' : 'user';

    } else {
      throw Exception("Invalid credentials");
    }
  }

  @override
  Future<void> register(String email, String password, String role) async {
    throw UnimplementedError("Use Django register API later");
  }

  @override
  Future<void> logout() async {
    _accessToken = null;
    _role = 'user';
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError("Use Django reset API later");
  }

  @override
  bool isLoggedIn() {
    return _accessToken != null;
  }

  @override
  String getRole() {
    return _role;
  }

  // EXTRA (we’ll use this later)
  String? get token => _accessToken;
}
