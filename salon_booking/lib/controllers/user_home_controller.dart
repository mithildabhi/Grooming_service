// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/salon_model.dart';
import '../models/service_model.dart';

class UserHomeController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<SalonModel> nearbySalons = <SalonModel>[].obs;
  final RxList<SalonModel> allSalons = <SalonModel>[].obs;
  
  // Selected salon for details page
  final Rxn<SalonModel> selectedSalon = Rxn<SalonModel>();
  final RxList<ServiceModel> salonServices = <ServiceModel>[].obs;
  final RxBool isLoadingServices = false.obs;

  // Getter for salons (returns all salons)
  List<SalonModel> get salons => allSalons.toList();

  @override
  void onInit() {
    super.onInit();
    fetchSalons();
  }

  /// Fetch all salons from Django backend
  Future<void> fetchSalons() async {
    try {
      isLoading.value = true;
      print('📥 Fetching salons from backend...');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salons/'),
      ).timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print('✅ Found ${data.length} salons');
        
        // Convert to SalonModel
        final salons = data.map((json) => SalonModel.fromJson(json)).toList();
        
        allSalons.value = salons;
        nearbySalons.value = salons; // For now, show all as nearby
        
        print('✅ Loaded ${salons.length} salons successfully');
      } else {
        print('❌ Failed to fetch salons: ${response.statusCode}');
        throw Exception('Failed to load salons');
      }
    } catch (e) {
      print('❌ Error fetching salons: $e');
      Get.snackbar(
        'Error',
        'Failed to load salons: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch services for a specific salon
  Future<void> fetchSalonServices(String salonId) async {
    try {
      isLoadingServices.value = true;
      print('📥 Fetching services for salon: $salonId');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/services/?salon=$salonId'),
      ).timeout(const Duration(seconds: 10));

      print('📊 Services response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print('✅ Found ${data.length} services');
        
        salonServices.value = data
            .map((json) => ServiceModel.fromJson(json))
            .toList();
        
        print('✅ Loaded ${salonServices.length} services');
      } else {
        print('⚠️ No services found for this salon');
        salonServices.clear();
      }
    } catch (e) {
      print('❌ Error fetching services: $e');
      salonServices.clear();
    } finally {
      isLoadingServices.value = false;
    }
  }

  /// Select a salon and navigate to details
  void selectSalon(SalonModel salon) {
    selectedSalon.value = salon;
    fetchSalonServices(salon.id);
    Get.toNamed('/user/salon-details', arguments: salon);
  }

  /// Calculate distance (mock for now)
  String getDistance(SalonModel salon) {
    // TODO: Implement real distance calculation using user location
    return '${(1.0 + (salon.id.hashCode % 50) / 10).toStringAsFixed(1)} km';
  }

  /// Check if salon is currently open
  bool isSalonOpen(SalonModel salon) {
    // TODO: Implement real time-based logic
    return salon.isOpen;
  }

  /// Refresh salons
  Future<void> refreshSalons() async {
    await fetchSalons();
  }
}