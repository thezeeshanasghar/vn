import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/widgets/app_app_bar.dart';
import '../core/widgets/loading_widget.dart';
import '../core/widgets/empty_state_widget.dart';
import '../core/widgets/clinic_card.dart';
import '../core/widgets/app_button.dart';
import '../core/router/app_routes.dart';
import 'dashboard_screen.dart';
import 'coming_soon_screen.dart';
import 'doctor_schedule_screen.dart';
import 'patient_list_screen.dart';
import 'inventory_screen.dart';
import 'personal_assistant_screen.dart';
import '../widgets/sidebar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final ClinicController _clinicController = Get.find<ClinicController>();
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    await _clinicController.loadClinics();
    
    // Smart routing based on clinic count
    if (_clinicController.clinics.isEmpty) {
      setState(() {
        _selectedIndex = 1; // Go to clinic section
      });
    }
  }


  Future<void> _navigateToClinicForm() async {
    final result = await Get.toNamed(AppRoutes.clinicForm);
    if (result == true) {
      _clinicController.loadClinics();
    }
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(clinics: _clinicController.clinics);
      case 1:
        return _buildClinicsView();
      case 2:
        // Patients: require one clinic to be online
        final onlineClinics = _clinicController.clinics.where((c) => c.isOnline).toList();
        if (onlineClinics.isEmpty) {
          return const ComingSoonScreen(title: 'Set a clinic Online to manage Patients');
        }
        final doctor = _authController.currentDoctor.value;
        if (doctor == null) {
          return const ComingSoonScreen(title: 'Please login again');
        }
        return PatientListScreen(
          doctorId: doctor.doctorId,
          clinicId: onlineClinics.first.clinicId,
        );
      case 3:
        return const DoctorScheduleScreen();
      case 4:
        return const InventoryScreen();
      case 5:
        return const PersonalAssistantScreen();
      case 6:
        return const ComingSoonScreen(title: 'Appointments');
      case 7:
        return const ComingSoonScreen(title: 'Medical Records');
      case 8:
        return const ComingSoonScreen(title: 'Settings');
      case 9:
        return const ComingSoonScreen(title: 'Help & Support');
      default:
        return DashboardScreen(clinics: _clinicController.clinics);
    }
  }

  Widget _buildClinicsView() {
    return Obx(() {
      if (_clinicController.isLoading.value) {
        return const LoadingWidget(message: 'Loading clinics...');
      }

      if (_clinicController.clinics.isEmpty) {
        return _buildNoClinicView();
      }

      return _buildClinicsList();
    });
  }

  Widget _buildNoClinicView() {
    return EmptyStateWidget(
      title: 'Welcome to Your Clinic Management',
      message: 'Get started by creating your first clinic.\nYou can manage multiple clinics from here.',
      icon: Icons.local_hospital_outlined,
      iconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      buttonText: 'Create Your First Clinic',
      onButtonTap: _navigateToClinicForm,
    );
  }

  Widget _buildClinicsList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Clinics',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${_clinicController.clinics.length} clinic${_clinicController.clinics.length == 1 ? '' : 's'} registered',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )),
                    ],
                  ),
                ),
                AppButton(
                  text: 'Add Clinic',
                  onPressed: _navigateToClinicForm,
                  type: AppButtonType.primary,
                  size: AppButtonSize.medium,
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Clinics List
            Obx(() => Column(
              children: _clinicController.clinics.map((clinic) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClinicCard(
                  clinic: clinic,
                  onTap: () => _editClinic(clinic),
                  onEdit: () => _editClinic(clinic),
                  onDelete: () => _deleteClinic(clinic),
                  onToggleOnline: () => _toggleClinicOnline(clinic),
                ),
              )).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _editClinic(clinic) async {
    final result = await Get.toNamed(AppRoutes.clinicForm, arguments: {
      'clinic': clinic,
      'isEditMode': true,
    });
                                if (result == true) {
      _clinicController.loadClinics();
    }
  }

  Future<void> _deleteClinic(clinic) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Clinic'),
        content: Text('Are you sure you want to delete "${clinic.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _clinicController.deleteClinic(clinic.id);
    }
  }

  Future<void> _toggleClinicOnline(clinic) async {
    if (clinic.isOnline && _clinicController.clinics.length > 1) {
      final onlineClinics = _clinicController.clinics.where((c) => c.isOnline).toList();
      if (onlineClinics.isNotEmpty) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Switch Clinic Online'),
            content: Text(
              'Setting "${clinic.name}" online will automatically set "${onlineClinics.first.name}" offline. '
              'Only one clinic can be online at a time. Continue?'
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        
        if (confirmed != true) return;
      }
    }

    await _clinicController.toggleClinicOnline(clinic.id, !clinic.isOnline);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_authController.currentDoctor.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRoutes.login);
      });
        return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
        appBar: AppAppBarWithUser(
          title: _getPageTitle(),
          userName: _authController.currentDoctor.value?.firstName != null
              ? 'Dr. ${_authController.currentDoctor.value!.firstName} ${_authController.currentDoctor.value!.lastName}'
              : null,
          userRole: _authController.currentDoctor.value?.type,
          onLogout: () => _authController.logout(),
        ),
        drawer: Drawer(
          child: SafeArea(
                child: Sidebar(
                  selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: _buildMainContent(),
      );
    });
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'My Clinic';
      case 2: return 'Patients';
      case 3: return 'Doctor Schedule';
      case 4: return 'Brand Inventory';
      case 5: return 'Personal Assistants';
      case 6: return 'Appointments';
      case 7: return 'Medical Records';
      case 8: return 'Settings';
      case 9: return 'Help & Support';
      default: return 'Dashboard';
    }
  }
}