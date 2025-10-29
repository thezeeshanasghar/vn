import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/empty_state_widget.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EmptyStateWidget(
        title: title,
        message: 'This feature is coming soon!\nWe\'re working hard to bring you the best experience.',
        icon: Icons.construction,
        iconColor: AppColors.warning,
        backgroundColor: AppColors.warning.withOpacity(0.1),
        buttonText: 'Back to Dashboard',
        onButtonTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}
