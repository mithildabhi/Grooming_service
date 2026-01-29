// lib/controllers/location_controller.dart

// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  // ========================
  // STATE
  // ========================
  
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString currentCity = ''.obs;
  final RxString currentState = ''.obs;
  final RxString currentAddress = ''.obs;
  
  final RxBool isLoadingLocation = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final RxBool isLocationServiceEnabled = false.obs;
  
  // ========================
  // GETTERS
  // ========================
  
  double? get latitude => currentPosition.value?.latitude;
  double? get longitude => currentPosition.value?.longitude;
  
  bool get hasLocation => currentPosition.value != null;
  
  String get locationDisplayText {
    if (currentCity.value.isNotEmpty) {
      return currentCity.value;
    } else if (currentAddress.value.isNotEmpty) {
      return currentAddress.value;
    }
    return 'Unknown Location';
  }
  
  // ========================
  // INITIALIZATION
  // ========================
  
  @override
  void onInit() {
    super.onInit();
    checkLocationServices();
  }
  
  /// Check if location services are available
  Future<void> checkLocationServices() async {
    isLocationServiceEnabled.value = await LocationService.isLocationServiceEnabled();
    
    final permission = await LocationService.checkPermission();
    hasLocationPermission.value = (
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse
    );
    
    print('📍 Location services: ${isLocationServiceEnabled.value}');
    print('📍 Location permission: ${hasLocationPermission.value}');
  }
  
  // ========================
  // GET LOCATION
  // ========================
  
  /// Get current GPS location
  Future<bool> getCurrentLocation({bool showDialog = true}) async {
    try {
      isLoadingLocation.value = true;
      
      final position = await LocationService.getCurrentPosition(
        showErrorDialog: showDialog,
      );
      
      if (position != null) {
        currentPosition.value = position;
        
        // Get city from coordinates
        await _updateLocationInfo(position.latitude, position.longitude);
        
        print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
        print('✅ City: ${currentCity.value}');
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error getting location: $e');
      return false;
    } finally {
      isLoadingLocation.value = false;
    }
  }
  
  /// Get last known location (faster)
  Future<bool> getLastKnownLocation() async {
    try {
      final position = await LocationService.getLastKnownPosition();
      
      if (position != null) {
        currentPosition.value = position;
        await _updateLocationInfo(position.latitude, position.longitude);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error getting last known location: $e');
      return false;
    }
  }
  
  /// Update location info from coordinates
  Future<void> _updateLocationInfo(double lat, double lon) async {
    try {
      final addressData = await LocationService.reverseGeocode(lat, lon);
      
      if (addressData != null) {
        currentCity.value = addressData['city'] ?? '';
        currentState.value = addressData['state'] ?? '';
        currentAddress.value = addressData['address'] ?? '';
        
        print('📍 Updated location info:');
        print('   City: ${currentCity.value}');
        print('   State: ${currentState.value}');
      }
    } catch (e) {
      print('❌ Error updating location info: $e');
    }
  }
  
  // ========================
  // GEOCODING
  // ========================
  
  /// Convert address to coordinates
  Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    return await LocationService.geocodeAddress(address);
  }
  
  /// Convert coordinates to address
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lon) async {
    return await LocationService.reverseGeocode(lat, lon);
  }
  
  // ========================
  // DISTANCE CALCULATION
  // ========================
  
  /// Calculate distance from current location
  double? calculateDistanceFromCurrent(double lat, double lon) {
    if (currentPosition.value == null) return null;
    
    return LocationService.calculateDistance(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      lat,
      lon,
    );
  }
  
  /// Calculate distance between two points
  static double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return LocationService.calculateDistance(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }
  
  // ========================
  // PERMISSION MANAGEMENT
  // ========================
  
  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final permission = await LocationService.requestPermission();
    
    hasLocationPermission.value = (
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse
    );
    
    return hasLocationPermission.value;
  }
  
  /// Show enable location dialog
  void showEnableLocationDialog() {
    LocationService.showEnableLocationDialog();
  }
  
  // ========================
  // CLEAR DATA
  // ========================
  
  void clearLocation() {
    currentPosition.value = null;
    currentCity.value = '';
    currentState.value = '';
    currentAddress.value = '';
    print('🧹 Location data cleared');
  }
}