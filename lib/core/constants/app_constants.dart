class AppConstants {
  AppConstants._();

  static const String appName = 'Feedback Hub';
  static const String appTagline = 'Collect • Analyze • Improve';
  static const String appVersion = '1.0.0';

  // Feedback Categories
  static const List<String> categories = [
    'General',
    'User Experience',
    'Feature Request',
    'Bug Report',
    'Performance',
    'Customer Support',
    'Course Content',
    'Company Environment',
  ];

  // User Roles
  static const String roleStudent = 'Student';
  static const String roleCompany = 'Company';

  // Sort Options
  static const String sortNewest = 'Newest';
  static const String sortOldest = 'Oldest';
  static const String sortHighestRating = 'Highest Rating';
  static const String sortLowestRating = 'Lowest Rating';

  // Statuses
  static const String statusPending = 'Pending';
  static const String statusReviewed = 'Reviewed';
  static const String statusResolved = 'Resolved';
}
