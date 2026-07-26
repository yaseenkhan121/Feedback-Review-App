import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/feedback_card.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../feedback/presentation/feedback_provider.dart';
import 'dashboard_provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _selectedRoleFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    final currentUser = authProvider.currentUser;
    String userName = 'User';
    if (currentUser?.name.isNotEmpty == true) {
      userName = currentUser!.name;
    } else if (currentUser?.email.isNotEmpty == true) {
      userName = currentUser!.email.split('@').first;
    }

    final userRole = currentUser?.role ?? 'Student';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    // Trigger dashboard analytics computation on feedback update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardProvider.computeAnalytics(feedbackProvider.feedbacks);
    });

    final feedbacksToDisplay = feedbackProvider.feedbacks.where((f) {
      if (_selectedRoleFilter == 'All') return true;
      return f.role.toLowerCase() == _selectedRoleFilter.toLowerCase();
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            feedbackProvider.listenToFeedbacks();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Avatar & Notification Icon
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Stack(
                        children: [
                          AppAvatar(
                            photoUrl: currentUser?.photoUrl ?? '',
                            initial: initial,
                            radius: 24,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: userRole.toLowerCase() == 'student'
                                    ? AppColors.studentRoleColor
                                    : AppColors.companyRoleColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Notification Button
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 10),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Icon(
                              Icons.notifications_outlined,
                              size: 22,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar Trigger
                GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkInputFill
                          : AppColors.lightInputFill,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: AppColors.lightTextMuted),
                        const SizedBox(width: 12),
                        Text(
                          'Search feedback, users, categories...',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Overview Cards Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Real-time Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      title: 'Total Feedback',
                      value: '${dashboardProvider.totalFeedback}',
                      trend: '+12.5%',
                      icon: Icons.chat_bubble_outline_rounded,
                      bgLight: const Color(0xFFEFF6FF),
                      iconColor: AppColors.primary,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      title: 'Avg Rating',
                      value: dashboardProvider.averageRating.toStringAsFixed(1),
                      trend: '+0.3',
                      icon: Icons.star_outline_rounded,
                      bgLight: const Color(0xFFFEF9C3),
                      iconColor: AppColors.warning,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      title: 'Students',
                      value: '${dashboardProvider.studentCount}',
                      trend: '+8.1%',
                      icon: Icons.school_outlined,
                      bgLight: const Color(0xFFF0FDF4),
                      iconColor: AppColors.success,
                      isDark: isDark,
                    ),
                    _buildStatCard(
                      title: 'Companies',
                      value: '${dashboardProvider.companyCount}',
                      trend: '+5.4%',
                      icon: Icons.business_outlined,
                      bgLight: const Color(0xFFF3E8FF),
                      iconColor: AppColors.secondary,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      label: 'Submit',
                      icon: Icons.add_comment_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/submit-feedback'),
                    ),
                    _buildActionButton(
                      label: 'Feedbacks',
                      icon: Icons.list_alt_rounded,
                      color: AppColors.secondary,
                      onTap: () => context.push('/feedback-list'),
                    ),
                    _buildActionButton(
                      label: 'Analytics',
                      icon: Icons.pie_chart_rounded,
                      color: const Color(0xFF0D9488),
                      onTap: () => context.push('/analytics'),
                    ),
                    _buildActionButton(
                      label: 'Profile',
                      icon: Icons.person_rounded,
                      color: const Color(0xFF9333EA),
                      onTap: () => context.push('/profile'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Feedback Section Header & Filter Tabs
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Feedback',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterTab('All', isDark),
                              const SizedBox(width: 4),
                              _buildFilterTab('Students', isDark),
                              const SizedBox(width: 4),
                              _buildFilterTab('Companies', isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Feedback List Stream View
                if (feedbackProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (feedbacksToDisplay.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined,
                            size: 48, color: AppColors.lightTextMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No feedback submissions found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedbacksToDisplay.length > 5 ? 5 : feedbacksToDisplay.length,
                    itemBuilder: (context, index) {
                      final item = feedbacksToDisplay[index];
                      return FeedbackCard(
                        feedback: item,
                        currentUserId: currentUser?.uid,
                        onTap: () => context.push('/feedback-details/${item.feedbackId}'),
                        onEdit: () => context.push('/edit-feedback/${item.feedbackId}'),
                        onDelete: () {
                          ConfirmationDialog.show(
                            context,
                            title: 'Delete Feedback',
                            message: 'Are you sure you want to delete this feedback?',
                            confirmText: 'Delete',
                            isDangerous: true,
                            onConfirm: () async {
                              final ok = await feedbackProvider.deleteFeedback(
                                item.feedbackId,
                                currentUser!.uid,
                              );
                              if (ok && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Feedback deleted successfully')),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color bgLight,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isDark) {
    final isSelected = _selectedRoleFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoleFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkInputFill
                  : AppColors.lightInputFill),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
