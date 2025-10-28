import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isClickable;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: Material(
        color: backgroundColor ?? AppColors.surface,
        elevation: elevation ?? 1, // Reduced elevation for subtler shadow
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        shadowColor: AppColors.shadow.withValues(alpha: 0.1), // Lighter shadow
        child: InkWell(
          onTap: isClickable ? onTap : null,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          splashColor: AppColors.primary.withValues(alpha: 0.1), // Added splash effect
          highlightColor: AppColors.primary.withValues(alpha: 0.05), // Added highlight effect
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5), // Lighter border
                width: 0.5, // Thinner border
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.white,
                  AppColors.white.withValues(alpha: 0.95),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
