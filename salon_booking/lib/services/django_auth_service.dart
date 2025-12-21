import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DjangoAuthService implements AuthService {
  static const String baseUrl = 'http://10.94.179.16:8000';

  String? _accessToken;
  String _role = 'user';

  @override
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": email, // email == username in Django
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access'];

      // TEMP role logic (can improve later)
      _role = email == 'admin' ? 'admin' : 'user';
    } else {
      throw Exception("Invalid credentials");
    }
  }

  @override
  Future<void> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Registration failed");
    }
  }

  @override
  String getRole() => _role;

  @override
  bool isLoggedIn() => _accessToken != null;

  @override
  Future<void> logout() async {
    _accessToken = null;
    _role = 'user';
  }

  @override
  Future<void> resetPassword(String email) async {
    throw UnimplementedError();
  }
}
