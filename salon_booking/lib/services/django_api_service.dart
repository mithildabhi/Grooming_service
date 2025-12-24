import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DjangoApiService {
  // static const String baseUrl = "http://10.97.98.16:8000/api";
  static const String baseUrl = 'http://192.168.29.87:8000/api';

  static Future<void> testAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ No Firebase user logged in");
      return;
    }

    try {
      final token = await user.getIdToken(true);
      
      print("🔥 Firebase Token: ${token?.substring(0, 50)}...");
      print("📤 Calling: $baseUrl/test-auth/");

      final response = await http.get(
        Uri.parse("$baseUrl/test-auth/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print("✅ Django Status Code: ${response.statusCode}");
      print("✅ Django Response Body: ${response.body}");
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  static Future<void> syncUser() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      print("❌ No Firebase user");
      return;
    }

    try {
      final token = await user.getIdToken();
      
      print("📤 Syncing to: $baseUrl/sync-user/");

      final response = await http.post(
        Uri.parse("$baseUrl/sync-user/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print("✅ Sync Status: ${response.statusCode}");
      print("✅ Sync Body: ${response.body}");
      
    } catch (e) {
      print("❌ Sync Error: $e");
    }
  }
}