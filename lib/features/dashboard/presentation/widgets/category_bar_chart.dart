import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryBarChart extends StatelessWidget {
  final Map<String, int> categoryCounts;
  final bool isDark;

  const CategoryBarChart({
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

    final categories = categoryCounts.keys.toList();
    final counts = categoryCounts.values.toList();
    final maxVal = (counts.isEmpty ? 5 : counts.reduce((a, b) => a > b ? a : b)).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal == 0 ? 5 : maxVal * 1.25,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (val, meta) => Text(
                      val.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx >= 0 && idx < categories.length) {
                        final catName = categories[idx];
                        final shortName = catName.length > 7
                            ? '${catName.substring(0, 6)}..'
                            : catName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            shortName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(categories.length, (i) {
                final count = categoryCounts[categories[i]]?.toDouble() ?? 0.0;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: count,
                      gradient: AppColors.primaryGradient,
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
