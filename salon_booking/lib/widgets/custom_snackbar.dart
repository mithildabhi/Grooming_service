import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    // Determine colors based on type
    Color iconColor = AppColors.primary;
    IconData iconData = Icons.info_outline;
    
    if (isError) {
      iconColor = AppColors.error;
      iconData = Icons.error_outline;
    } else if (isSuccess) {
      iconColor = AppColors.success;
      iconData = Icons.check_circle_outline;
    }

    // Using Get.snackbar but completely customizing the content
    Get.snackbar(
      title, // Logic handled below to minimize default rendering
      message, // Logic handled below
      titleText: const SizedBox.shrink(),
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subHeading.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      snackPosition: position,
      backgroundColor: Colors.transparent,
      colorText: Colors.transparent,
      borderRadius: 0,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      barBlur: 0,
      overlayBlur: 0,
      duration: duration,
      animationDuration: const Duration(milliseconds: 600),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
