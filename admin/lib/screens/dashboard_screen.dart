import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/app_app_bar.dart';
import '../core/widgets/app_drawer.dart';
import '../core/widgets/loading_state_widget.dart';
import '../core/widgets/error_state_widget.dart';
import '../core/widgets/dashboard_layout_widget.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final DashboardController controller = Get.find<DashboardController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final RxString currentRoute = '/dashboard'.obs;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Dashboard',
        subtitle: 'Management System',
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Obx(() => IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.isLoading.value ? null : controller.refreshData,
          )),
        ],
      ),
      drawer: AppDrawer(
        currentRoute: currentRoute.value,
        onItemTap: (route) {
          currentRoute.value = route;
          Get.toNamed(route);
        },
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(DashboardController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingStateWidget();
      }

      if (controller.hasError) {
        return ErrorStateWidget(
          message: controller.errorMessage.value,
          onRetry: controller.refreshData,
        );
      }

      return DashboardLayoutWidget(
        controller: controller,
        // quickActions: _getQuickActions(),
        // recentActivities: _getRecentActivities(),
      );
    });
  }

  // List<QuickActionItem> _getQuickActions() {
  //   return [
  //     const QuickActionItem(
  //       icon: Icons.add,
  //       title: 'Add New Vaccine',
  //       subtitle: 'Register a new vaccine',
  //       onTap: null, // Will be handled by parent
  //     ),
  //     const QuickActionItem(
  //       icon: Icons.person_add,
  //       title: 'Add Doctor',
  //       subtitle: 'Register a new doctor',
  //       onTap: null,
  //     ),
  //     const QuickActionItem(
  //       icon: Icons.business,
  //       title: 'Add Brand',
  //       subtitle: 'Register a new brand',
  //       onTap: null,
  //     ),
  //     const QuickActionItem(
  //       icon: Icons.analytics,
  //       title: 'View Reports',
  //       subtitle: 'Check system reports',
  //       onTap: null,
  //     ),
  //   ];
  // }
  //
  // List<ActivityItem> _getRecentActivities() {
  //   return [
  //     const ActivityItem(
  //       icon: Icons.vaccines,
  //       title: 'New vaccine added',
  //       subtitle: 'COVID-19 Booster',
  //       time: '2 hours ago',
  //       color: AppColors.success,
  //     ),
  //     const ActivityItem(
  //       icon: Icons.person_add,
  //       title: 'Doctor registered',
  //       subtitle: 'Dr. Sarah Johnson',
  //       time: '4 hours ago',
  //       color: AppColors.info,
  //     ),
  //     const ActivityItem(
  //       icon: Icons.business,
  //       title: 'Brand updated',
  //       subtitle: 'Pfizer Inc.',
  //       time: '6 hours ago',
  //       color: AppColors.warning,
  //     ),
  //     const ActivityItem(
  //       icon: Icons.analytics,
  //       title: 'Report generated',
  //       subtitle: 'Monthly Statistics',
  //       time: '1 day ago',
  //       color: AppColors.primary,
  //     ),
  //   ];
  // }

}
