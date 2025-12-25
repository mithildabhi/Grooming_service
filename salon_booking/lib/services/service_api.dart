import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceApi {
  static const String baseUrl = 'http://192.168.29.87:8000/api/services';

  static Future<List<ServiceModel>> fetchServices() async {
    final res = await http.get(Uri.parse('$baseUrl/'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data
          .map<ServiceModel>(
            (e) => ServiceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    throw Exception('Failed to load services');
  }

  static Future<void> createService({
    required String token,
    required String name,
    required String description,
    required double price,
    required int duration,
    required String category,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/create/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'duration': duration,
        'category': category,
      }),
    );
  }

  static Future<void> deleteService({
    required String token,
    required int serviceId,
  }) async {
    await http.delete(
      Uri.parse('$baseUrl/$serviceId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
