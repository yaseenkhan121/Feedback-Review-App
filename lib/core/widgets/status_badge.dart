import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case AppConstants.statusResolved:
        bg = AppColors.success.withAlpha(30);
        fg = AppColors.success;
        break;
      case AppConstants.statusReviewed:
        bg = AppColors.info.withAlpha(30);
        fg = AppColors.info;
        break;
      case AppConstants.statusPending:
      default:
        bg = AppColors.warning.withAlpha(30);
        fg = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
