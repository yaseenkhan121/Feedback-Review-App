import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final double iconSize;
  final bool isInteractive;

  const RatingWidget({
    super.key,
    required this.rating,
    this.onRatingChanged,
    this.iconSize = 28,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFilled = rating >= starValue;
        final isHalf = rating > index && rating < starValue;

        return GestureDetector(
          onTap: isInteractive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              isHalf
                  ? Icons.star_half_rounded
                  : (isFilled ? Icons.star_rounded : Icons.star_outline_rounded),
              size: iconSize,
              color: isFilled || isHalf ? AppColors.warning : AppColors.lightTextMuted,
            ),
          ),
        );
      }),
    );
  }
}
