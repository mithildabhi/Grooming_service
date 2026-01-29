// lib/widgets/city_selector_widget.dart - ENHANCED WITH GPS

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_home_controller.dart';
import '../controllers/location_controller.dart';
import '../theme/app_colors.dart';

class CitySelectorWidget extends StatelessWidget {
  const CitySelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserHomeController homeController = Get.find<UserHomeController>();

    return Obx(() {
      // Loading state
      if (homeController.isLoadingCities.value) {
        return _buildLoadingState();
      }

      // No cities available
      if (homeController.availableCities.isEmpty) {
        return const SizedBox.shrink();
      }

      // City selector button
      return GestureDetector(
        onTap: () => _showCityPicker(context, homeController),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                homeController.useGpsLocation.value 
                    ? Icons.my_location 
                    : Icons.location_on,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  homeController.cityDisplayText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context, UserHomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find salons near you',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(color: AppColors.divider, height: 1),
            
            // ✅ NEW: Use Current Location Option
            Obx(() => _buildUseGpsTile(
              context: context,
              controller: controller,
              isSelected: controller.useGpsLocation.value,
            )),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR SELECT CITY',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
            ),
            
            // Cities List
            Flexible(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: controller.availableCities.length,
                itemBuilder: (context, index) {
                  final city = controller.availableCities[index];
                  final isSelected = city == controller.selectedCity.value && 
                                    !controller.useGpsLocation.value;
                  final isAllCities = city == 'All Cities';
                  
                  return _buildCityTile(
                    context: context,
                    city: city,
                    isSelected: isSelected,
                    isAllCities: isAllCities,
                    onTap: () {
                      controller.changeCity(city);
                      Navigator.pop(context);
                    },
                  );
                },
              )),
            ),
            
            // Bottom safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildUseGpsTile({
    required BuildContext context,
    required UserHomeController controller,
    required bool isSelected,
  }) {
    // Get location controller
    final locationCtrl = Get.isRegistered<LocationController>() 
        ? Get.find<LocationController>() 
        : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.my_location,
            color: isSelected
                ? AppColors.primary
                : AppColors.textMuted,
            size: 20,
          ),
        ),
        title: Text(
          'Use Current Location',
          style: TextStyle(
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        subtitle: locationCtrl != null && locationCtrl.hasLocation
            ? Text(
                locationCtrl.locationDisplayText,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : const Text(
                'Find salons nearest to you',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 16,
                ),
              )
            : null,
        onTap: () async {
          await controller.toggleGpsLocation();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildCityTile({
    required BuildContext context,
    required String city,
    required bool isSelected,
    required bool isAllCities,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isAllCities ? Icons.public : Icons.location_city,
            color: isSelected
                ? AppColors.primary
                : AppColors.textMuted,
            size: 20,
          ),
        ),
        title: Text(
          city,
          style: TextStyle(
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.w500,
            color: isSelected
                ? AppColors.primary
                : AppColors.textPrimary,
            fontSize: 15,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 16,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}