import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MonthlyLineChart extends StatelessWidget {
  final Map<String, int> monthlyCounts;
  final bool isDark;

  const MonthlyLineChart({
    super.key,
    required this.monthlyCounts,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (monthlyCounts.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No monthly feedback trend data available',
            style: TextStyle(color: AppColors.lightTextMuted, fontSize: 13),
          ),
        ),
      );
    }

    final keys = monthlyCounts.keys.toList();
    final values = monthlyCounts.values.toList();
    final maxVal = (values.isEmpty ? 5 : values.reduce((a, b) => a > b ? a : b)).toDouble();

    final spots = <FlSpot>[];
    for (int i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxVal == 0 ? 5 : maxVal * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (val) => FlLine(
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
                  final idx = val.toInt();
                  if (idx >= 0 && idx < keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        keys[idx],
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
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: AppColors.primaryGradient,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withAlpha(35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
