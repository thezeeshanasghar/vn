import 'package:get/get.dart';
import '../core/services/dashboard_service.dart';

class DashboardController extends GetxController {
  // Observable variables
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, int> stats = <String, int>{}.obs;

  // Individual stat observables
  final RxInt vaccinesCount = 0.obs;
  final RxInt brandsCount = 0.obs;
  final RxInt dosesCount = 0.obs;
  final RxInt doctorsCount = 0.obs;
  final RxInt usersCount = 156.obs; // Static value

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check connection first
      final isConnected = await DashboardService.checkConnection();
      if (!isConnected) {
        throw Exception('Unable to connect to server. Please check your internet connection.');
      }

      // Fetch dashboard statistics
      final dashboardStats = await DashboardService.getDashboardStats();

      // Update observables
      stats.value = dashboardStats;
      vaccinesCount.value = dashboardStats['vaccines'] ?? 0;
      brandsCount.value = dashboardStats['brands'] ?? 0;
      dosesCount.value = dashboardStats['doses'] ?? 0;
      doctorsCount.value = dashboardStats['doctors'] ?? 0;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      // Error loading dashboard data: $e
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // Get trend data (mock data for now)
  String getTrendText(String type) {
    switch (type) {
      case 'vaccines':
        return '+12%';
      case 'brands':
        return '+8%';
      case 'doses':
        return '+15%';
      case 'doctors':
        return '+5%';
      case 'users':
        return '+23%';
      default:
        return '+0%';
    }
  }

  // Check if data is loaded successfully
  bool get hasData => stats.isNotEmpty && !isLoading.value && errorMessage.isEmpty;

  // Check if there's an error
  bool get hasError => errorMessage.isNotEmpty;
}
