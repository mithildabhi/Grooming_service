import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DjangoApiService {
<<<<<<< Updated upstream
  static const String baseUrl = "http://10.94.179.16/api";
=======
  static const String baseUrl = "http://10.97.98.16:8000/api";
  // static const String baseUrl = 'http://192.168.29.87:8000/api';
>>>>>>> Stashed changes

  static Future<void> testAuth() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ No Firebase user logged in");
      return;
    }

    final token = await user.getIdToken(true);
    
    // 🔥 VERY IMPORTANT DEBUG LINE
    print("🔥 Firebase Token Sent to Django:");
    print(token);

    final response = await http.get(
      Uri.parse("$baseUrl/test-auth/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print("✅ Django Status Code: ${response.statusCode}");
    print("✅ Django Response Body: ${response.body}");
  }


  static Future<void> syncUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await user.getIdToken();

  await http.post(
    Uri.parse("$baseUrl/sync-user/"),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      },
    );
  }

}


