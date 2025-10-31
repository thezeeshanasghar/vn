import 'package:flutter/material.dart';
import '../../models/clinic.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_card.dart';
import 'app_button.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleOnline;
  final bool showActions;

  const ClinicCard({
    super.key,
    required this.clinic,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleOnline,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: clinic.logo != null && clinic.logo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          clinic.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_hospital,
                              color: AppColors.grey400,
                              size: 28,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.local_hospital,
                        color: AppColors.grey400,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${clinic.clinicId} • ${clinic.regNo}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 20),
          
          // Details
          _buildDetailRow(Icons.location_on_outlined, clinic.address),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.phone_outlined, clinic.phoneNumber),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.attach_money_outlined, '₹${clinic.clinicFee.toStringAsFixed(0)}'),
          
          if (showActions) ...[
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: clinic.isOnline ? AppColors.success.withOpacity(0.1) : AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: clinic.isOnline ? AppColors.success : AppColors.grey300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: clinic.isOnline ? AppColors.success : AppColors.grey400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            clinic.isOnline ? 'Online' : 'Offline',
            style: AppTextStyles.caption.copyWith(
              color: clinic.isOnline ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onEdit != null) ...[
          Expanded(
            child: AppButton(
              text: 'Edit',
              onPressed: onEdit,
              type: AppButtonType.outline,
              size: AppButtonSize.small,
              icon: Icons.edit_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onToggleOnline != null) ...[
          Expanded(
            child: AppButton(
              text: clinic.isOnline ? 'Offline' : 'Online',
              onPressed: onToggleOnline,
              type: clinic.isOnline ? AppButtonType.danger : AppButtonType.success,
              size: AppButtonSize.small,
              icon: clinic.isOnline ? Icons.visibility_off : Icons.visibility,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onDelete != null) ...[
          Expanded(
            child: AppButton(
              text: 'Delete',
              onPressed: onDelete,
              type: AppButtonType.danger,
              size: AppButtonSize.small,
              icon: Icons.delete_outlined,
            ),
          ),
        ],
      ],
    );
  }
}
