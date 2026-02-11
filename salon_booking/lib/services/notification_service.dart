import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  static final _firebaseMessaging = FirebaseMessaging.instance;

  // Request permission
  static Future<void> init() async {

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Get token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
