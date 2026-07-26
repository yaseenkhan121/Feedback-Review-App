import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const CustomErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'We encountered an error while processing your request. Please try again.',
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (onRetry != null)
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Retry',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ),
            if (onGoBack != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: CustomButton(
                  text: 'Go Back',
                  isOutlined: true,
                  onPressed: onGoBack,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
