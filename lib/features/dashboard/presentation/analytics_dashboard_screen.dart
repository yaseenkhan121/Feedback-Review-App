import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import 'dashboard_provider.dart';
import 'widgets/category_bar_chart.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/monthly_line_chart.dart';
import 'widgets/rating_distribution_chart.dart';
import 'widgets/weekly_activity_chart.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Analytics'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: dashboardProvider.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Calculating real-time analytics from Firestore...',
                      style: TextStyle(fontSize: 13, color: AppColors.lightTextMuted),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Sync Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.success.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Live Firestore Sync Active • Auto Updates',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          Text(
                            '${dashboardProvider.totalFeedback} Docs',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Top Metric Grid Cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMetricCard(
                          title: 'Total Feedback',
                          value: '${dashboardProvider.totalFeedback}',
                          subtitle: 'All Submissions',
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Average Rating',
                          value: dashboardProvider.averageRating.toStringAsFixed(1),
                          subtitle: 'Out of 5.0 Stars',
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Highest Rating',
                          value: dashboardProvider.highestRating == 0
                              ? '0.0'
                              : '${dashboardProvider.highestRating.toStringAsFixed(1)} ★',
                          subtitle: 'Max Score Given',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Lowest Rating',
                          value: dashboardProvider.lowestRating == 0
                              ? '0.0'
                              : '${dashboardProvider.lowestRating.toStringAsFixed(1)} ★',
                          subtitle: 'Min Score Given',
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Student Posts',
                          value: '${dashboardProvider.studentCount}',
                          subtitle: 'Role: Student',
                          color: AppColors.studentRoleColor,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Company Posts',
                          value: '${dashboardProvider.companyCount}',
                          subtitle: 'Role: Company',
                          color: AppColors.companyRoleColor,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Pending Status',
                          value: '${dashboardProvider.pendingCount}',
                          subtitle: 'Awaiting Action',
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                        _buildMetricCard(
                          title: 'Resolved Status',
                          value: '${dashboardProvider.resolvedCount}',
                          subtitle: 'Completed Action',
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Insights & Aggregation Details Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 10),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real-Time Key Insights',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInsightItem(
                                  label: 'Most Active User',
                                  value: dashboardProvider.mostActiveUser,
                                  color: AppColors.primary,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInsightItem(
                                  label: 'Most Used Category',
                                  value: dashboardProvider.mostUsedCategory,
                                  color: AppColors.secondary,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInsightItem(
                                  label: 'Highest Rated Cat.',
                                  value: dashboardProvider.highestRatedCategory,
                                  color: AppColors.success,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInsightItem(
                                  label: 'Lowest Rated Cat.',
                                  value: dashboardProvider.lowestRatedCategory,
                                  color: AppColors.error,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart 1: Bar Chart — Category Volume
                    _buildChartCard(
                      title: '1. Feedback Count by Category (Bar Chart)',
                      subtitle: 'Total submissions per category',
                      isDark: isDark,
                      child: CategoryBarChart(
                        categoryCounts: dashboardProvider.categoryCounts,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart 2: Pie Chart — Category Distribution
                    _buildChartCard(
                      title: '2. Category Distribution (Pie Chart)',
                      subtitle: 'Percentage share of feedback',
                      isDark: isDark,
                      child: CategoryPieChart(
                        categoryCounts: dashboardProvider.categoryCounts,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart 3: Line Chart — Monthly Trend
                    _buildChartCard(
                      title: '3. Monthly Submissions Trend (Line Chart)',
                      subtitle: 'Submission volume over past 6 months',
                      isDark: isDark,
                      child: MonthlyLineChart(
                        monthlyCounts: dashboardProvider.monthlyCounts,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart 4: Rating Distribution Chart
                    _buildChartCard(
                      title: '4. Rating Distribution (1★ to 5★)',
                      subtitle: 'Breakdown of ratings awarded',
                      isDark: isDark,
                      child: RatingDistributionChart(
                        ratingDistribution: dashboardProvider.ratingDistribution,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart 5: Weekly Activity Chart
                    _buildChartCard(
                      title: '5. Weekly Activity Breakdown',
                      subtitle: 'Submissions grouped by day of the week',
                      isDark: isDark,
                      child: WeeklyActivityChart(
                        weeklyCounts: dashboardProvider.weeklyCounts,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Breakdown Data Table
                    _buildCategoryTable(dashboardProvider, isDark),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryTable(DashboardProvider provider, bool isDark) {
    final catCounts = provider.categoryCounts;
    final catAvg = provider.categoryAvgRatings;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Performance Table',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          if (catCounts.isEmpty)
            const Text(
              'No category data recorded yet.',
              style: TextStyle(fontSize: 13, color: AppColors.lightTextMuted),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Category',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Submissions',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Avg Rating',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                  ],
                ),
                ...catCounts.entries.map((e) {
                  final avg = catAvg[e.key] ?? 0.0;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(e.key, style: const TextStyle(fontSize: 13)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('${e.value}', style: const TextStyle(fontSize: 13)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('${avg.toStringAsFixed(1)} ★',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning)),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
