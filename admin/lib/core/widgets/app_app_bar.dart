import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final VoidCallback? onMenuTap;

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading ?? _buildDefaultLeading(context),
      title: _buildTitle(),
      actions: actions ?? _buildDefaultActions(context),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
    );
  }

  Widget _buildDefaultLeading(BuildContext context) {
    return IconButton(
      onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
      icon: const Icon(
        Icons.menu,
        color: AppColors.white,
        size: 24,
      ),
    );
  }

  Widget _buildTitle() {
    if (subtitle != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    }
    
    return Text(
      title,
      style: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          // Add refresh functionality
        },
        icon: const Icon(
          Icons.refresh,
          color: AppColors.white,
          size: 24,
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
