import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/presentation/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Preferences', isDark),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: _buildIconContainer(
                          Icons.dark_mode_outlined, AppColors.primary),
                      title: const Text('Dark Mode',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      value: themeProvider.isDarkMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: _buildIconContainer(
                          Icons.notifications_outlined, AppColors.secondary),
                      title: const Text('Push Notifications',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      value: _pushNotifications,
                      activeThumbColor: AppColors.secondary,
                      onChanged: (val) {
                        setState(() {
                          _pushNotifications = val;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.language_rounded, AppColors.info),
                      title: const Text('Language',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: Text(
                        _selectedLanguage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedLanguage =
                              _selectedLanguage == 'English' ? 'Spanish' : 'English';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Security & Legal', isDark),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.shield_outlined, const Color(0xFF0D9488)),
                      title: const Text('Privacy Policy',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.article_outlined, const Color(0xFF9333EA)),
                      title: const Text('Terms of Service',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.info_outline_rounded, AppColors.primary),
                      title: const Text('About Feedback Hub',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: Text(
                        'v${AppConstants.appVersion}',
                        style: const TextStyle(fontSize: 12, color: AppColors.lightTextMuted),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('Account Actions', isDark),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.logout_rounded, AppColors.warning),
                      title: const Text('Logout',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      onTap: () {
                        ConfirmationDialog.show(
                          context,
                          title: 'Confirm Logout',
                          message: 'Are you sure you want to log out?',
                          confirmText: 'Logout',
                          onConfirm: () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _buildIconContainer(
                          Icons.delete_forever_rounded, AppColors.error),
                      title: const Text('Delete Account',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.error)),
                      onTap: () {
                        ConfirmationDialog.show(
                          context,
                          title: 'Delete Account',
                          message:
                              'This action is permanent and will remove all your data. Continue?',
                          confirmText: 'Delete Forever',
                          isDangerous: true,
                          onConfirm: () async {
                            await authProvider.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
