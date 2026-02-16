import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/api_config.dart';

class NotificationService {

  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // HIGH IMPORTANCE CHANNEL FOR ANDROID
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  // Request permission
  static Future<void> init() async {
    try {
      print("🚀 Initializing Notification Service...");
      
      // 1. Request Permission
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Initialize Local Notifications
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            print("🎯 Local Notification Clicked: ${details.payload}");
          }
        },
      );

      // 3. Create High Importance Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
          
      print("✅ Notification Service Initialized Successfully");
    } catch (e) {
      print("❌ Error Initializing Notification Service: $e");
      // Don't rethrow, let the app continue to boot
    }
  }

  // Show system tray notification
  static Future<void> showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            priority: Priority.high,
            importance: Importance.max,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  // Get token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Save token to backend
  static Future<void> saveTokenToBackend(String token, String authToken) async {
    try {
      print("📤 Saving FCM Token to backend...");
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/save-fcm/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        print('✅ FCM Token saved to backend');
      } else {
        print('❌ Failed to save FCM token: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  
  // 🔔 Trigger Test Notification (For Debugging)
  static Future<void> triggerTestNotification() async {
    try {
      String? token = await getToken();
      if (token == null) {
        Get.snackbar("Error", "FCM Token is null. Cannot test.");
        return;
      }

      print("🔔 Sending Test Notification to: $token");
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/test-fcm/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        print('✅ Test Notification Sent Successfully');
        Get.snackbar("Success", "Test Notification Sent! Check status bar.", 
          backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        print('❌ Failed to send test notification: ${response.statusCode}');
        print('Response: ${response.body}');
        Get.snackbar("Error", "Failed: ${response.statusCode}", 
          backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('❌ Error triggering test notification: $e');
      Get.snackbar("Error", "Exception: $e", 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
