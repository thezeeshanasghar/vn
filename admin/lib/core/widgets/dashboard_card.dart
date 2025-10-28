import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_card.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final String? trendText;
  final Color? trendColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.showTrend = false,
    this.trendText,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      isClickable: onTap != null,
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10), // Reduced from 12 to 10
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20, // Reduced from 24 to 20
                ),
              ),
              if (showTrend && trendText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced padding
                  decoration: BoxDecoration(
                    color: (trendColor ?? AppColors.success).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: trendColor ?? AppColors.success,
                        size: 14, // Reduced from 16 to 14
                      ),
                      const SizedBox(width: 3), // Reduced from 4 to 3
                      Text(
                        trendText!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: trendColor ?? AppColors.success,
                          fontSize: 11, // Added smaller font size
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12), // Reduced from 16 to 12
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.numberLarge.copyWith(
                  fontSize: 24, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2), // Reduced from 4 to 2
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13, // Reduced font size
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
