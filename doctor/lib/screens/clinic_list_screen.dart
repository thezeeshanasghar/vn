import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/widgets/app_app_bar.dart';
import '../core/widgets/loading_widget.dart';
import '../core/widgets/empty_state_widget.dart';
import '../core/widgets/clinic_card.dart';
import '../core/widgets/app_button.dart';
import '../core/router/app_routes.dart';

class ClinicListScreen extends StatelessWidget {
  const ClinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClinicController clinicController = Get.find<ClinicController>();

    return Scaffold(
      appBar: AppAppBar(
        title: 'My Clinics',
        actions: [
          AppButton(
            text: 'Add Clinic',
            onPressed: () async {
              final result = await Get.toNamed(AppRoutes.clinicForm);
              if (result == true) {
                clinicController.loadClinics();
              }
            },
            type: AppButtonType.primary,
            size: AppButtonSize.small,
            icon: Icons.add,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Obx(() {
          if (clinicController.isLoading.value) {
            return const LoadingWidget(message: 'Loading clinics...');
          }

          if (clinicController.clinics.isEmpty) {
            return _buildNoClinicView();
          }

          return _buildClinicsView();
        }),
      ),
    );
  }

  Widget _buildNoClinicView() {
    return EmptyStateWidget(
      title: 'No Clinic Found',
      message: 'You haven\'t added your clinic yet.\nAdd your clinic to get started.',
      icon: Icons.local_hospital_outlined,
      iconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      buttonText: 'Add Clinic',
      onButtonTap: () async {
        final result = await Get.toNamed(AppRoutes.clinicForm);
                if (result == true) {
          Get.find<ClinicController>().loadClinics();
        }
      },
    );
  }

  Widget _buildClinicsView() {
    final ClinicController clinicController = Get.find<ClinicController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: AppColors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'My Clinics',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '${clinicController.clinics.length} clinic${clinicController.clinics.length == 1 ? '' : 's'} registered',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Clinics Grid
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: clinicController.clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinicController.clinics[index];
              return ClinicCard(
                clinic: clinic,
                onTap: () => _editClinic(clinic),
                onEdit: () => _editClinic(clinic),
                onDelete: () => _deleteClinic(clinic),
                onToggleOnline: () => _toggleClinicOnline(clinic),
              );
            },
          )),
        ],
      ),
    );
  }

  Future<void> _editClinic(clinic) async {
    final result = await Get.toNamed(AppRoutes.clinicForm, arguments: {
      'clinic': clinic,
      'isEditMode': true,
    });
    if (result == true) {
      Get.find<ClinicController>().loadClinics();
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
      await Get.find<ClinicController>().deleteClinic(clinic.id);
    }
  }

  Future<void> _toggleClinicOnline(clinic) async {
    final clinicController = Get.find<ClinicController>();
    
    if (clinic.isOnline && clinicController.clinics.length > 1) {
      final onlineClinics = clinicController.clinics.where((c) => c.isOnline).toList();
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

    await clinicController.toggleClinicOnline(clinic.id, !clinic.isOnline);
  }
}