import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/widgets/app_card.dart';
import '../core/controllers/auth_controller.dart';
import '../core/controllers/clinic_controller.dart';
import '../core/router/app_routes.dart';
import '../models/clinic.dart';

class DashboardScreen extends StatelessWidget {
  final List<Clinic>? clinics;
  
  const DashboardScreen({super.key, this.clinics});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ClinicController clinicController = Get.find<ClinicController>();
    final doctor = authController.currentDoctor.value;
    final hasClinics = clinicController.clinics.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(doctor, hasClinics),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeCard(doctor),
                const SizedBox(height: 20),
                _buildQuickActionsGrid(),
                const SizedBox(height: 20),
                _buildStatsOverview(),
                const SizedBox(height: 20),
                _buildClinicStatusCard(hasClinics),
                const SizedBox(height: 20),
                _buildRecentActivity(),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(dynamic doctor, bool hasClinics) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
      child: Padding(
              padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.white.withValues(alpha: 0.2),
                        child: doctor?.imageUrl != null && doctor.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  doctor.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      doctor?.firstName?[0]?.toUpperCase() ?? 'D',
                                      style: AppTextStyles.h2.copyWith(color: AppColors.white),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                doctor?.firstName?[0]?.toUpperCase() ?? 'D',
                                style: AppTextStyles.h2.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                              'Good ${_getGreeting()}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                      Text(
                              'Dr. ${doctor?.lastName ?? 'User'}',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                          color: hasClinics 
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasClinics ? AppColors.success : AppColors.warning,
                            width: 1,
                          ),
                  ),
                  child: Text(
                    hasClinics ? 'Active' : 'Setup',
                          style: AppTextStyles.caption.copyWith(
                            color: hasClinics ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
                ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic doctor) {
    return AppCard(
      padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Your Dashboard',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your practice efficiently',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.email_outlined,
                  'Email',
                  doctor?.email ?? 'doctor@example.com',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  Icons.phone_outlined,
                  'Phone',
                  doctor?.mobileNumber ?? '+1234567890',
                ),
              ),
            ],
          ),
          if (doctor?.qualifications != null && doctor.qualifications.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoItem(
              Icons.school_outlined,
              'Qualifications',
              doctor.qualifications,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              icon: Icons.people_outline,
              title: 'Patients',
              subtitle: 'Manage patients',
              color: AppColors.primary,
              onTap: () => Get.toNamed(AppRoutes.patients),
            ),
            _buildActionCard(
              icon: Icons.calendar_today_outlined,
              title: 'Appointments',
              subtitle: 'View schedule',
              color: AppColors.secondary,
              onTap: () => Get.toNamed(AppRoutes.appointments),
            ),
            _buildActionCard(
              icon: Icons.medical_information_outlined,
              title: 'Records',
              subtitle: 'Medical records',
              color: AppColors.accent,
              onTap: () => Get.toNamed(AppRoutes.medicalRecords),
            ),
            _buildActionCard(
              icon: Icons.local_hospital_outlined,
              title: 'Clinics',
              subtitle: 'Manage clinics',
              color: AppColors.success,
              onTap: () => Get.toNamed(AppRoutes.clinicList),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
            Text(
                title,
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                title: 'Patients',
                value: '24',
                subtitle: 'Today',
                color: AppColors.primary,
                trend: '+12%',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.event_outlined,
                title: 'Appointments',
                value: '8',
                subtitle: 'Scheduled',
                color: AppColors.secondary,
                trend: '+3',
                isPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer_outlined,
                title: 'Wait Time',
                value: '15m',
                subtitle: 'Average',
                color: AppColors.accent,
                trend: '-5m',
                isPositive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star_outline,
                title: 'Rating',
                value: '4.8',
                subtitle: 'Patient',
                color: AppColors.success,
                trend: '+0.2',
                isPositive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.caption.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicStatusCard(bool hasClinics) {
    final ClinicController clinicController = Get.find<ClinicController>();
    
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasClinics 
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasClinics ? Icons.local_hospital : Icons.local_hospital_outlined,
                  color: hasClinics ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    Text(
                      hasClinics ? 'Clinic Status' : 'Setup Required',
                      style: AppTextStyles.h5.copyWith(
                        color: hasClinics ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasClinics 
                          ? '${clinicController.clinics.length} clinic${clinicController.clinics.length > 1 ? 's' : ''} registered'
                          : 'Create your first clinic to get started',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasClinics)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (hasClinics && clinicController.clinics.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'Your Clinics',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...clinicController.clinics.take(2).map((clinic) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: clinic.isOnline ? AppColors.success : AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '₹${clinic.clinicFee.toStringAsFixed(0)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            )).toList(),
            if (clinicController.clinics.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '+${clinicController.clinics.length - 2} more clinics',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ] else if (!hasClinics) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.clinicForm),
                icon: const Icon(Icons.add),
                label: const Text('Create Your First Clinic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'New patient registered',
                subtitle: 'Sarah Johnson - 2 hours ago',
                color: AppColors.success,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.event,
                title: 'Appointment completed',
                subtitle: 'John Smith - 3 hours ago',
                color: AppColors.primary,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                icon: Icons.medical_information,
                title: 'Medical record updated',
                subtitle: 'Emma Wilson - 5 hours ago',
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}