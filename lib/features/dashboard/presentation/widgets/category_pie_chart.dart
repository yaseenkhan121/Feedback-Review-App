import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final bool isDark;

  const CategoryPieChart({
    super.key,
    required this.categoryCounts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryCounts.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No feedback category data available',
            style: TextStyle(color: AppColors.lightTextMuted, fontSize: 13),
          ),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      const Color(0xFF9333EA),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    final entries = categoryCounts.entries.toList();
    final total = categoryCounts.values.fold<int>(0, (sum, val) => sum + val);

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: List.generate(entries.length, (i) {
                  final count = entries[i].value;
                  final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: count.toDouble(),
                    title: '$pct%',
                    radius: 40,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (ctx, i) {
                final cat = entries[i].key;
                final count = entries[i].value;
                final pct = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$count ($pct%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
