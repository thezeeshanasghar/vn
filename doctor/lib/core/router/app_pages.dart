import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/clinic_controller.dart';
import '../../screens/login_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/clinic_list_screen.dart';
import '../../screens/clinic_form_screen.dart';
import '../../screens/coming_soon_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(ClinicController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(ClinicController());
      }),
    ),
    GetPage(
      name: AppRoutes.clinicList,
      page: () => const ClinicListScreen(),
      binding: BindingsBuilder(() {
        Get.put(ClinicController());
      }),
    ),
    GetPage(
      name: AppRoutes.clinicForm,
      page: () => const ClinicFormScreen(),
      binding: BindingsBuilder(() {
        Get.put(ClinicController());
      }),
    ),
    GetPage(
      name: AppRoutes.patients,
      page: () => const ComingSoonScreen(title: 'Patients Management'),
    ),
    GetPage(
      name: AppRoutes.appointments,
      page: () => const ComingSoonScreen(title: 'Appointments'),
    ),
    GetPage(
      name: AppRoutes.medicalRecords,
      page: () => const ComingSoonScreen(title: 'Medical Records'),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const ComingSoonScreen(title: 'Settings'),
    ),
    GetPage(
      name: AppRoutes.help,
      page: () => const ComingSoonScreen(title: 'Help & Support'),
    ),
  ];
}
