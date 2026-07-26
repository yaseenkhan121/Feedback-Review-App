import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'New Feedback Submitted',
        message: 'Sarah Johnson submitted feedback on User Experience.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
        type: 'feedback',
      ),
      NotificationModel(
        id: '2',
        title: 'Status Updated',
        message: 'Your feedback regarding Bug Report was marked as Resolved.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'status',
      ),
      NotificationModel(
        id: '3',
        title: 'Welcome to Feedback Hub',
        message: 'Thank you for registering your account on Feedback Hub!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppColors.lightTextMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Updates',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearAll,
                          child: const Text(
                            'Clear All',
                            style: TextStyle(fontSize: 12, color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _notifications.length,
                      itemBuilder: (ctx, i) {
                        final n = _notifications[i];
                        return _buildNotificationCard(n, isDark);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel n, bool isDark) {
    IconData icon;
    Color color;

    switch (n.type) {
      case 'status':
        icon = Icons.check_circle_outline_rounded;
        color = AppColors.success;
        break;
      case 'system':
        icon = Icons.info_outline_rounded;
        color = AppColors.secondary;
        break;
      case 'feedback':
      default:
        icon = Icons.chat_bubble_outline_rounded;
        color = AppColors.primary;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.isRead
            ? (isDark ? AppColors.darkCard : Colors.white)
            : (isDark
                ? AppColors.primary.withAlpha(25)
                : AppColors.primary.withAlpha(15)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: n.isRead
              ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
              : AppColors.primary.withAlpha(80),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (!n.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormatter.formatRelative(n.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
