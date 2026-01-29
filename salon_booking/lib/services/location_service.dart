// lib/services/location_service.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  // ========================
  // GPS LOCATION
  // ========================
  
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission;
  }
  
  /// Get current position with error handling
  static Future<Position?> getCurrentPosition({
    bool showErrorDialog = true,
  }) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        if (showErrorDialog) {
          Get.snackbar(
            'Location Disabled',
            'Please enable location services',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
        return null;
      }
      
      // Check permission
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        
        if (permission == LocationPermission.denied) {
          if (showErrorDialog) {
            Get.snackbar(
              'Permission Denied',
              'Location permission is required',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (showErrorDialog) {
          _showPermissionDeniedDialog();
        }
        return null;
      }
      
      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      print('📍 Current position: ${position.latitude}, ${position.longitude}');
      return position;
      
    } catch (e) {
      print('❌ Error getting location: $e');
      
      if (showErrorDialog) {
        Get.snackbar(
          'Location Error',
          'Could not get your location',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      
      return null;
    }
  }
  
  /// Get last known position (faster, but may be outdated)
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('❌ Error getting last known position: $e');
      return null;
    }
  }
  
  /// Calculate distance between two coordinates (in kilometers)
  static double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    ) / 1000; // Convert meters to kilometers
  }
  
  // ========================
  // GEOCODING (using Nominatim - FREE)
  // ========================
  
  /// Geocode address to coordinates
  static Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search');
      
      final response = await http.get(
        url.replace(queryParameters: {
          'q': address,
          'format': 'json',
          'limit': '1',
        }),
        headers: {'User-Agent': 'SalonBookingApp/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        if (data.isNotEmpty) {
          final result = data[0];
          return {
            'lat': double.parse(result['lat']),
            'lon': double.parse(result['lon']),
            'display_name': result['display_name'],
          };
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Geocoding error: $e');
      return null;
    }
  }
  
  /// Reverse geocode coordinates to address
  static Future<Map<String, dynamic>?> reverseGeocode(
    double lat,
    double lon,
  ) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse');
      
      final response = await http.get(
        url.replace(queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
        }),
        headers: {'User-Agent': 'SalonBookingApp/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['address'] != null) {
          final addr = data['address'];
          
          // Extract components
          final city = addr['city'] ?? 
                       addr['town'] ?? 
                       addr['village'] ?? 
                       addr['municipality'] ?? 
                       '';
          
          final state = addr['state'] ?? 
                        addr['state_district'] ?? 
                        '';
          
          final pincode = addr['postcode'] ?? '';
          final country = addr['country'] ?? '';
          
          return {
            'address': data['display_name'] ?? '',
            'city': city,
            'state': state,
            'pincode': pincode,
            'country': country,
          };
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Reverse geocoding error: $e');
      return null;
    }
  }
  
  /// Get city from coordinates
  static Future<String?> getCityFromCoordinates(
    double lat,
    double lon,
  ) async {
    final addressData = await reverseGeocode(lat, lon);
    return addressData?['city'];
  }
  
  // ========================
  // PERMISSION DIALOGS
  // ========================
  
  static void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to show nearby salons. '
          'Please enable location permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  /// Show dialog asking user to enable GPS
  static void showEnableLocationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services to find nearby salons.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            child: const Text('Enable'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  // ========================
  // LOCATION STREAM
  // ========================
  
  /// Listen to location updates
  static Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Update every 10 meters
  }) {
    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );
    
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}