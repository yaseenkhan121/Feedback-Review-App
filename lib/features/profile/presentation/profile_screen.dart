import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../feedback/presentation/feedback_provider.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    final currentUser = authProvider.currentUser;
    final uid = currentUser?.uid ?? '';

    final userFeedbacks = uid.isEmpty
        ? []
        : feedbackProvider.feedbacks.where((f) => f.submittedBy == uid).toList();
    final userFeedbackCount = userFeedbacks.length;
    final avgRatingGiven = userFeedbacks.isEmpty
        ? 0.0
        : userFeedbacks.fold<double>(0.0, (sum, item) => sum + item.rating) /
            userFeedbacks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: uid.isNotEmpty
              ? ProfileRepository().getProfileStream(uid)
              : Stream.value(currentUser),
          initialData: currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data ?? currentUser;
            final userName = user?.name.isNotEmpty == true
                ? user!.name
                : (user?.email.isNotEmpty == true
                    ? user!.email.split('@').first
                    : 'User');
            final userEmail = user?.email ?? '';
            final userRole = user?.role ?? 'Student';
            final photoUrl = user?.photoUrl ?? '';
            final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

            final isStudentRole = userRole.toLowerCase() == 'student';
            final roleColor = isStudentRole
                ? AppColors.studentRoleColor
                : AppColors.companyRoleColor;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // User Profile Avatar Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        Stack(
                          children: [
                            AppAvatar(
                              photoUrl: photoUrl,
                              initial: initial,
                              radius: 48,
                              backgroundColor: roleColor,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  isStudentRole
                                      ? Icons.school_rounded
                                      : Icons.business_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Role Badge & Edit Button Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: roleColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$userRole Account',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: roleColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => context.push('/edit-profile'),
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Edit Profile', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Statistics Overview Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildProfileStatCard(
                          title: 'Submitted',
                          value: '$userFeedbackCount',
                          icon: Icons.chat_bubble_outline_rounded,
                          color: AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildProfileStatCard(
                          title: 'Avg Rating',
                          value: avgRatingGiven.toStringAsFixed(1),
                          icon: Icons.star_outline_rounded,
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildProfileStatCard(
                          title: 'Member Since',
                          value: DateFormatter.formatMonthYear(
                              user?.createdAt ?? DateTime.now()),
                          color: AppColors.success,
                          icon: Icons.calendar_today_rounded,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Options & Settings List Container
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildOptionTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile & Avatar',
                          onTap: () => context.push('/edit-profile'),
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          value: themeProvider.isDarkMode,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            themeProvider.toggleTheme(val);
                          },
                        ),
                        const Divider(height: 1),
                        _buildOptionTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () => context.push('/notifications'),
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildOptionTile(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () => context.push('/settings'),
                          isDark: isDark,
                        ),
                        const Divider(height: 1),
                        _buildOptionTile(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          textColor: AppColors.error,
                          iconColor: AppColors.error,
                          onTap: () {
                            ConfirmationDialog.show(
                              context,
                              title: 'Confirm Logout',
                              message: 'Are you sure you want to log out of Feedback Hub?',
                              confirmText: 'Logout',
                              isDangerous: true,
                              onConfirm: () async {
                                await authProvider.logout();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                            );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? textColor,
    Color? iconColor,
  }) {
    final iColor = iconColor ?? AppColors.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ??
              (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
