import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onItemTap;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildMenuItems(context),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Panel',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Management',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: AppColors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      _MenuItemData(
        icon: Icons.dashboard,
        title: 'Dashboard',
        route: '/dashboard',
      ),
      _MenuItemData(
        icon: Icons.vaccines,
        title: 'Vaccines',
        route: '/vaccines',
      ),
      _MenuItemData(
        icon: Icons.business,
        title: 'Brands',
        route: '/brands',
      ),
      _MenuItemData(
        icon: Icons.medical_services,
        title: 'Doctors',
        route: '/doctors',
      ),
      _MenuItemData(
        icon: Icons.medication,
        title: 'Doses',
        route: '/doses',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = currentRoute == item.route;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color:         isSelected 
            ? AppColors.white.withValues(alpha: 0.2)
            : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onItemTap(item.route);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected 
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected 
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.7),
                        fontWeight: isSelected 
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Admin Management System',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String route;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.route,
  });
}
