import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RatingDistributionChart extends StatelessWidget {
  final Map<int, int> ratingDistribution; // 1: count, 2: count, etc.
  final bool isDark;

  const RatingDistributionChart({
    super.key,
    required this.ratingDistribution,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final values = ratingDistribution.values.toList();
    final maxVal = (values.isEmpty ? 5 : values.reduce((a, b) => a > b ? a : b)).toDouble();

    final starColors = {
      5: AppColors.success,
      4: const Color(0xFF84CC16),
      3: AppColors.warning,
      2: const Color(0xFFF97316),
      1: AppColors.error,
    };

    return SizedBox(
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
                reservedSize: 28,
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
                getTitlesWidget: (val, meta) {
                  final star = val.toInt() + 1;
                  if (star >= 1 && star <= 5) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '$star ★',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: starColors[star] ?? AppColors.primary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: List.generate(5, (i) {
            final star = i + 1;
            final count = ratingDistribution[star]?.toDouble() ?? 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count,
                  color: starColors[star] ?? AppColors.primary,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
