import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;
  final double? size;

  const LoadingStateWidget({
    super.key,
    this.message = 'Loading dashboard data...',
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}
