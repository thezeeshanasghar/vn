import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import 'responsive_layout.dart';
import 'dashboard_card.dart';
import 'welcome_section_widget.dart';
import 'quick_actions_widget.dart';
import 'recent_activity_widget.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardLayoutWidget extends StatelessWidget {
  final DashboardController controller;
  final List<QuickActionItem> quickActions;
  final List<ActivityItem> recentActivities;

  const DashboardLayoutWidget({
    super.key,
    required this.controller,
    this.quickActions = const [],
    this.recentActivities = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildMobileLayout(),
      desktop: _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return ResponsivePadding(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Reduced from 20 to 16
            const WelcomeSectionWidget(),
            const SizedBox(height: 20), // Reduced from 24 to 20
            _buildStatsGrid(1),
            const SizedBox(height: 20), // Reduced from 24 to 20
            // QuickActionsWidget(actions: quickActions),
            // const SizedBox(height: 20),
            // RecentActivityWidget(activities: recentActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return ResponsivePadding(
      tabletPadding: const EdgeInsets.all(20), // Reduced from 24 to 20
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Reduced from 20 to 16
            const WelcomeSectionWidget(),
            const SizedBox(height: 20), // Reduced from 24 to 20
            SizedBox(
              height: _calculateGridHeight(4),
              child: ResponsiveGrid(
                mobileColumns: 2,
                tabletColumns: 4,
                desktopColumns: 6,
                spacing: 12.0,
                runSpacing: 12.0,
                children: _buildDashboardCards(),
              ),
            ),
            const SizedBox(height: 20), // Reduced from 24 to 20
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: QuickActionsWidget(actions: quickActions),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: RecentActivityWidget(activities: recentActivities),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return ResponsivePadding(
      desktopPadding: const EdgeInsets.all(24), // Reduced from 32 to 24
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Reduced from 20 to 16
            const WelcomeSectionWidget(),
            const SizedBox(height: 24), // Reduced from 32 to 24
            SizedBox(
              height: _calculateGridHeight(6),
              child: ResponsiveGrid(
                mobileColumns: 2,
                tabletColumns: 4,
                desktopColumns: 6,
                spacing: 12.0,
                runSpacing: 12.0,
                children: _buildDashboardCards(),
              ),
            ),
            const SizedBox(height: 24), // Reduced from 32 to 24
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: QuickActionsWidget(actions: quickActions),
                ),
                const SizedBox(width: 20), // Reduced from 24 to 20
                Expanded(
                  flex: 1,
                  child: RecentActivityWidget(activities: recentActivities),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(int crossAxisCount) {
    return ResponsiveGrid(
      mobileColumns: crossAxisCount,
      tabletColumns: crossAxisCount,
      desktopColumns: crossAxisCount,
      children: _buildDashboardCards(),
    );
  }

  double _calculateGridHeight(int crossAxisCount) {
    const double cardHeight = 100.0; // Reduced from 120 to 100
    const double spacing = 12.0; // Reduced from 16 to 12
    const int itemCount = 5;
    
    final int rowCount = (itemCount / crossAxisCount).ceil();
    return (rowCount * cardHeight) + ((rowCount - 1) * spacing);
  }

  List<Widget> _buildDashboardCards() {
    return [
      Obx(() => _buildDashboardCard(
        title: 'Vaccines',
        value: controller.vaccinesCount.value.toString(),
        icon: Icons.vaccines,
        iconColor: AppColors.cardVaccines,
        trendText: controller.getTrendText('vaccines'),
        onTap: () => _navigateToRoute('/vaccines'),
      )),
      Obx(() => _buildDashboardCard(
        title: 'Brands',
        value: controller.brandsCount.value.toString(),
        icon: Icons.business,
        iconColor: AppColors.cardBrands,
        trendText: controller.getTrendText('brands'),
        onTap: () => _navigateToRoute('/brands'),
      )),
      Obx(() => _buildDashboardCard(
        title: 'Doses',
        value: controller.dosesCount.value.toString(),
        icon: Icons.medication,
        iconColor: AppColors.cardDoses,
        trendText: controller.getTrendText('doses'),
        onTap: () => _navigateToRoute('/doses'),
      )),
      Obx(() => _buildDashboardCard(
        title: 'Doctors',
        value: controller.doctorsCount.value.toString(),
        icon: Icons.medical_services,
        iconColor: AppColors.cardDoctors,
        trendText: controller.getTrendText('doctors'),
        onTap: () => _navigateToRoute('/doctors'),
      )),
      Obx(() => _buildDashboardCard(
        title: 'Users',
        value: controller.usersCount.value.toString(),
        icon: Icons.people,
        iconColor: AppColors.cardUsers,
        trendText: controller.getTrendText('users'),
        onTap: () => _navigateToRoute('/users'),
      )),
    ];
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String trendText,
    required VoidCallback onTap,
  }) {
    return DashboardCard(
      title: title,
      value: value,
      icon: icon,
      iconColor: iconColor,
      showTrend: true,
      trendText: trendText,
      trendColor: AppColors.success,
      onTap: onTap,
    );
  }

  void _navigateToRoute(String route) {
    // Navigation logic here - using GetX routing
    Get.toNamed(route);
  }
}
