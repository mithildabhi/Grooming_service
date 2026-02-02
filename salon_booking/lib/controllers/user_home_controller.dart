// lib/controllers/user_home_controller.dart
// ✅ COMPLETE: Full GPS location support + distance calculation

// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';
import 'user_controller.dart';
import 'location_controller.dart';

class UserHomeController extends GetxController {
  // ========================
  // STATE MANAGEMENT
  // ========================
  final RxBool isLoading = true.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isLoadingServices = false.obs;
  final RxBool useGpsLocation = false.obs;  // ✅ FIXED: Only one declaration
  
  final RxList<SalonModel> allSalons = <SalonModel>[].obs;
  final RxList<SalonModel> nearbySalons = <SalonModel>[].obs;
  
  final Rxn<SalonModel> selectedSalon = Rxn<SalonModel>();
  final RxList<ServiceModel> salonServices = <ServiceModel>[].obs;
  
  // ✅ City filtering
  final RxString selectedCity = 'All Cities'.obs;
  final RxList<String> availableCities = <String>[].obs;
  
  // ✅ Location-based filtering
  final RxDouble searchRadius = 10.0.obs; // km
  
  // ✅ Error handling
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // ========================
  // GETTERS
  // ========================
  List<SalonModel> get salons => allSalons.toList();
  
  bool get hasCityFilter => selectedCity.value != 'All Cities';
  
  String get cityDisplayText {
    if (useGpsLocation.value) {
      final locationCtrl = Get.isRegistered<LocationController>() 
          ? Get.find<LocationController>() 
          : null;
      if (locationCtrl?.hasLocation == true) {
        return 'Near ${locationCtrl!.currentCity.value}';
      }
      return 'Near You';
    }
    
    if (selectedCity.value == 'All Cities') {
      return 'All Cities';
    }
    return selectedCity.value;
  }

  // ========================
  // INITIALIZATION
  // ========================
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// ✅ OPTIMIZED: Single initialization flow
  Future<void> _initializeApp() async {
    try {
      print('🚀 HOME: Initializing app...');
      
      // ✅ Initialize location controller if not already registered
      if (!Get.isRegistered<LocationController>()) {
        Get.put(LocationController());
      }
      
      // Run in parallel for faster loading
      await Future.wait([
        _loadUserCity(),
        fetchAvailableCities(),
      ]);
      
      // Then fetch salons
      await fetchSalons();
      
      print('✅ HOME: App initialized successfully');
    } catch (e) {
      print('❌ HOME: Initialization error: $e');
      errorMessage.value = 'Failed to initialize';
      hasError.value = true;
    }
  }

  /// ✅ OPTIMIZED: Load user's city from profile
  Future<void> _loadUserCity() async {
    try {
      if (!Get.isRegistered<UserController>()) {
        print('⚠️ HOME: UserController not registered');
        selectedCity.value = 'All Cities';
        return;
      }
      
      final userController = Get.find<UserController>();
      
      // Wait for user data with timeout
      int attempts = 0;
      while (!userController.isDataLoaded.value && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }
      
      if (userController.userCity.value.isNotEmpty) {
        selectedCity.value = userController.userCity.value;
        print('🌍 HOME: User city loaded: ${selectedCity.value}');
      } else {
        selectedCity.value = 'All Cities';
        print('🔍 HOME: No city in profile, showing all');
      }
    } catch (e) {
      print('❌ HOME: Error loading user city: $e');
      selectedCity.value = 'All Cities';
    }
  }

  // ========================
  // ✅ GPS LOCATION TOGGLE
  // ========================
  
  /// Toggle GPS location filtering
  Future<void> toggleGpsLocation() async {
    if (useGpsLocation.value) {
      // ✅ Disable GPS filtering
      useGpsLocation.value = false;
      print('📍 HOME: GPS location disabled, switching to city filter');
      await fetchSalons();
    } else {
      // ✅ Enable GPS filtering
      final locationCtrl = Get.find<LocationController>();
      
      // Get current location if not already available
      if (!locationCtrl.hasLocation) {
        print('📍 HOME: Getting current location...');
        
        // Get.dialog(
        //   const Center(
        //     child: CircularProgressIndicator(),
        //   ),
        //   barrierDismissible: false,
        // );
        
        final success = await locationCtrl.getCurrentLocation(showDialog: false);
        
        if (Get.isDialogOpen == true) {
          Get.back(); // Close loading dialog
        }
        
        if (!success) {
          Get.snackbar(
            'Location Required',
            'Please enable location to find nearby salons',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }
      
      useGpsLocation.value = true;
      print('📍 HOME: GPS location enabled');
      
      // ✅ Fetch salons with GPS coordinates
      await fetchSalons();
      
      Get.snackbar(
        'Location Enabled',
        'Showing salons near you',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  // ========================
  // ✅ FETCH NEARBY SALONS (GPS)
  // ========================
  
  /// Fetch nearby salons using GPS coordinates
  Future<void> fetchNearbySalons({double? radius}) async {
    try {
      final locationCtrl = Get.find<LocationController>();
      
      if (!locationCtrl.hasLocation) {
        Get.snackbar(
          'Location Required',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      isLoading.value = true;
      
      final lat = locationCtrl.latitude!;
      final lon = locationCtrl.longitude!;
      final searchRadius = radius ?? this.searchRadius.value;
      
      print('📍 HOME: Fetching salons within ${searchRadius}km of ($lat, $lon)');
      
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/salons/nearby/?lat=$lat&lon=$lon&radius=$searchRadius'
        ),
      ).timeout(const Duration(seconds: 15));
      
      print('📊 HOME: Nearby salons response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> salonsData = data['results'] ?? [];
        
        final salons = <SalonModel>[];
        for (var json in salonsData) {
          try {
            final salon = SalonModel.fromJson(json as Map<String, dynamic>);
            salons.add(salon);
          } catch (e) {
            print('⚠️ HOME: Error parsing salon: $e');
          }
        }
        
        allSalons.value = salons;
        nearbySalons.value = salons;
        
        print('✅ HOME: Found ${salons.length} nearby salons');
        
        if (salons.isEmpty) {
          errorMessage.value = 'No salons found within ${searchRadius}km';
          Get.snackbar(
            'No Salons Found',
            'Try increasing the search radius or selecting a specific city',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ HOME: Error fetching nearby salons: $e');
      Get.snackbar(
        'Error',
        'Could not load nearby salons',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // FETCH CITIES
  // ========================
  
  /// Fetch available cities from backend
  Future<void> fetchAvailableCities() async {
    try {
      isLoadingCities.value = true;
      print('🌍 HOME: Fetching available cities...');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salons/cities/'),
      ).timeout(const Duration(seconds: 10));

      print('📊 HOME: Cities response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ SAFE: Handle both formats
        List<dynamic> citiesList;
        if (data is Map && data.containsKey('cities')) {
          citiesList = data['cities'] ?? [];
        } else if (data is List) {
          citiesList = data;
        } else {
          citiesList = [];
        }
        
        availableCities.value = citiesList
            .map((c) => c.toString())
            .where((c) => c.isNotEmpty)
            .toList();
        
        // Add "All Cities" at the beginning
        if (!availableCities.contains('All Cities')) {
          availableCities.insert(0, 'All Cities');
        }
        
        print('✅ HOME: Found ${availableCities.length} cities');
      } else {
        print('⚠️ HOME: Cities API returned ${response.statusCode}');
      }
    } catch (e) {
      print('❌ HOME: Error fetching cities: $e');
      // Add at least "All Cities" as fallback
      if (!availableCities.contains('All Cities')) {
        availableCities.add('All Cities');
      }
    } finally {
      isLoadingCities.value = false;
    }
  }

  // ========================
  // ✅ FETCH SALONS WITH LOCATION
  // ========================
  
  /// Fetch salons with optional city filter and distance calculation
  Future<void> fetchSalons({String? city}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      // ✅ If GPS location is enabled, use nearby endpoint
      if (useGpsLocation.value) {
        print('📍 HOME: Using GPS mode - fetching nearby salons');
        await fetchNearbySalons();
        return;
      }
      
      final filterCity = city ?? selectedCity.value;
      
      // Build URL with city filter
      String url = '${ApiConfig.baseUrl}/salons/';
      Map<String, String> queryParams = {};
      
      if (filterCity.isNotEmpty && filterCity != 'All Cities') {
        queryParams['city'] = filterCity;
        print('🌍 HOME: Fetching salons for city: $filterCity');
      } else {
        print('🌍 HOME: Fetching all salons');
      }
      
      // ✅ NEW: Add user location for distance calculation (even in city mode)
      if (Get.isRegistered<LocationController>()) {
        final locationCtrl = Get.find<LocationController>();
        if (locationCtrl.hasLocation) {
          queryParams['lat'] = locationCtrl.latitude.toString();
          queryParams['lon'] = locationCtrl.longitude.toString();
          print('📍 HOME: Including user location for distance calculation');
        }
      }
      
      // Build final URL
      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
      
      print('🔗 HOME: Fetching from: $url');
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 15));

      print('📊 HOME: Salons response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ CRITICAL FIX: Handle both response formats
        List<dynamic> salonsData;
        
        if (data is Map) {
          if (data.containsKey('results')) {
            salonsData = data['results'] as List<dynamic>;
          } else if (data.containsKey('data')) {
            salonsData = data['data'] as List<dynamic>;
          } else {
            print('⚠️ HOME: Unexpected Map format: ${data.keys}');
            salonsData = [];
          }
        } else if (data is List) {
          salonsData = data;
        } else {
          print('❌ HOME: Unexpected response type: ${data.runtimeType}');
          salonsData = [];
        }
        
        print('📊 HOME: Found ${salonsData.length} salons');
        
        // Convert to SalonModel with error handling
        final salons = <SalonModel>[];
        for (var json in salonsData) {
          try {
            final salon = SalonModel.fromJson(json as Map<String, dynamic>);
            salons.add(salon);
          } catch (e) {
            print('⚠️ HOME: Error parsing salon: $e');
            print('   Data: $json');
          }
        }
        
        allSalons.value = salons;
        nearbySalons.value = salons;
        
        print('✅ HOME: Successfully loaded ${salons.length} salons');
        
        if (salons.isEmpty) {
          errorMessage.value = filterCity == 'All Cities'
              ? 'No salons available yet'
              : 'No salons found in $filterCity';
        }
        
      } else {
        print('❌ HOME: Failed to fetch salons: ${response.statusCode}');
        print('   Body: ${response.body}');
        throw Exception('Server returned ${response.statusCode}');
      }
      
    } catch (e, stackTrace) {
      print('❌ HOME: Error fetching salons: $e');
      print('   Stack: $stackTrace');
      
      hasError.value = true;
      errorMessage.value = 'Failed to load salons';
      
      Get.snackbar(
        'Error',
        'Failed to load salons: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========================
  // CHANGE CITY
  // ========================
  
  /// Change city and reload salons
  Future<void> changeCity(String city) async {
    if (city == selectedCity.value) return;
    
    // ✅ Disable GPS if switching to city filter
    useGpsLocation.value = false;
    
    selectedCity.value = city;
    print('🌍 HOME: City changed to: $city');
    
    // Reload salons for new city
    await fetchSalons(city: city);
    
    // Show feedback
    Get.snackbar(
      'Location Changed',
      city == 'All Cities' 
        ? 'Showing salons from all cities'
        : 'Showing salons in $city',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ========================
  // FETCH SERVICES
  // ========================
  
  /// Fetch services for a specific salon
  Future<void> fetchSalonServices(String salonId) async {
    try {
      isLoadingServices.value = true;
      print('🔥 HOME: Fetching services for salon: $salonId');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/services/?salon=$salonId'),
      ).timeout(const Duration(seconds: 10));

      print('📊 HOME: Services response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle both formats
        List<dynamic> servicesData;
        if (data is Map && data.containsKey('results')) {
          servicesData = data['results'];
        } else if (data is List) {
          servicesData = data;
        } else {
          servicesData = [];
        }
        
        salonServices.value = servicesData
            .map((json) => ServiceModel.fromJson(json))
            .toList();
        
        print('✅ HOME: Loaded ${salonServices.length} services');
      } else {
        print('⚠️ HOME: No services found');
        salonServices.clear();
      }
    } catch (e) {
      print('❌ HOME: Error fetching services: $e');
      salonServices.clear();
    } finally {
      isLoadingServices.value = false;
    }
  }

  // ========================
  // NAVIGATION
  // ========================
  
  /// Select a salon and navigate to details
  void selectSalon(SalonModel salon) {
    selectedSalon.value = salon;
    fetchSalonServices(salon.id);
    Get.toNamed('/salon-details', arguments: salon);
  }

  // ========================
  // UTILITIES
  // ========================
  
  /// Calculate distance from user's current location
  String getDistanceText(SalonModel salon) {
    if (salon.distance > 0) {
      return '${salon.distance.toStringAsFixed(1)} km';
    }
    
    return '--';
  }

  /// Check if salon is currently open
  bool isSalonOpen(SalonModel salon) {
    return salon.isOpen;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchSalons(),
      fetchAvailableCities(),
    ]);
  }

  /// Refresh salons only
  Future<void> refreshSalons() async {
    await fetchSalons();
  }
  
  // ========================
  // CLEANUP
  // ========================
  
  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}