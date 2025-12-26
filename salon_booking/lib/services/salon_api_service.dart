import 'dart:convert';
import 'package:http/http.dart' as http;

class SalonApiService {
  // static const String baseUrl = 'http://192.168.29.87:8000/api';
  static const String baseUrl = 'http://10.94.179.16:8000/api';

  static Future<List<dynamic>> fetchSalons(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/salons/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load salons');
    }
  }
}
