import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Glassmorphism card. Safe in Column, ListView, Sliver.
/// When used inside [Row], pass explicit [width] to avoid unbounded width.
/// Default [width] is [double.infinity] so it takes full cross-axis in list/column.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  /// When null, uses [double.infinity] (full width in Column/ListView).
  /// In [Row], pass an explicit width (e.g. 48, or MediaQuery width) to avoid RenderBox errors.
  final double? width;
  final double? height;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.width,
    this.height,
    this.color,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}
