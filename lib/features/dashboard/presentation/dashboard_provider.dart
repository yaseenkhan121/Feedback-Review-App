import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/feedback_model.dart';
import '../data/analytics_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  StreamSubscription<List<FeedbackModel>>? _streamSubscription;

  bool _isLoading = true;
  String? _errorMessage;

  int _totalFeedback = 0;
  double _averageRating = 0.0;
  double _highestRating = 0.0;
  double _lowestRating = 0.0;

  int _studentCount = 0;
  int _companyCount = 0;
  int _pendingCount = 0;
  int _resolvedCount = 0;

  Map<String, int> _categoryCounts = {};
  Map<String, double> _categoryAvgRatings = {};
  Map<String, int> _monthlyCounts = {};
  Map<String, int> _weeklyCounts = {}; // Mon, Tue, Wed, Thu, Fri, Sat, Sun
  Map<int, int> _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  List<FeedbackModel> _latestFeedback = [];
  String _mostActiveUser = 'N/A';
  String _mostUsedCategory = 'N/A';
  String _highestRatedCategory = 'N/A';
  String _lowestRatedCategory = 'N/A';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalFeedback => _totalFeedback;
  double get averageRating => _averageRating;
  double get highestRating => _highestRating;
  double get lowestRating => _lowestRating;

  int get studentCount => _studentCount;
  int get companyCount => _companyCount;
  int get pendingCount => _pendingCount;
  int get resolvedCount => _resolvedCount;

  Map<String, int> get categoryCounts => _categoryCounts;
  Map<String, double> get categoryAvgRatings => _categoryAvgRatings;
  Map<String, int> get monthlyCounts => _monthlyCounts;
  Map<String, int> get weeklyCounts => _weeklyCounts;
  Map<int, int> get ratingDistribution => _ratingDistribution;

  List<FeedbackModel> get latestFeedback => _latestFeedback;
  String get mostActiveUser => _mostActiveUser;
  String get mostUsedCategory => _mostUsedCategory;
  String get highestRatedCategory => _highestRatedCategory;
  String get lowestRatedCategory => _lowestRatedCategory;

  DashboardProvider() {
    initRealTimeAnalyticsListener();
  }

  /// Establishes real-time Stream listener directly from Firestore
  void initRealTimeAnalyticsListener() {
    _isLoading = true;
    notifyListeners();

    _streamSubscription?.cancel();
    _streamSubscription = _analyticsRepository.getFeedbackStream().listen(
      (list) {
        computeAnalytics(list);
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString().replaceAll('Exception: ', '');
        notifyListeners();
      },
    );
  }

  /// Aggregates metrics live from actual Firestore documents
  void computeAnalytics(List<FeedbackModel> list) {
    if (list.isEmpty) {
      _totalFeedback = 0;
      _averageRating = 0.0;
      _highestRating = 0.0;
      _lowestRating = 0.0;
      _studentCount = 0;
      _companyCount = 0;
      _pendingCount = 0;
      _resolvedCount = 0;
      _categoryCounts = {};
      _categoryAvgRatings = {};
      _monthlyCounts = {};
      _weeklyCounts = {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0
      };
      _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      _latestFeedback = [];
      _mostActiveUser = 'None';
      _mostUsedCategory = 'None';
      _highestRatedCategory = 'None';
      _lowestRatedCategory = 'None';
      return;
    }

    // 1. Total Feedback & Rating Aggregations
    _totalFeedback = list.length;
    final totalRatingSum = list.fold<double>(0.0, (sum, f) => sum + f.rating);
    _averageRating = totalRatingSum / _totalFeedback;

    final ratingsList = list.map((f) => f.rating).toList();
    _highestRating = ratingsList.reduce((a, b) => a > b ? a : b);
    _lowestRating = ratingsList.reduce((a, b) => a < b ? a : b);

    // 2. Role & Status Counts
    _studentCount = list.where((f) => f.role.toLowerCase() == 'student').length;
    _companyCount = list.where((f) => f.role.toLowerCase() == 'company').length;
    _pendingCount = list.where((f) => f.status.toLowerCase() == 'pending').length;
    _resolvedCount = list.where((f) => f.status.toLowerCase() == 'resolved').length;

    // 3. Category Counts & Average Ratings
    final catCountsMap = <String, int>{};
    final catTotalRatingMap = <String, double>{};

    for (var item in list) {
      catCountsMap[item.category] = (catCountsMap[item.category] ?? 0) + 1;
      catTotalRatingMap[item.category] =
          (catTotalRatingMap[item.category] ?? 0.0) + item.rating;
    }

    _categoryCounts = catCountsMap;
    _categoryAvgRatings = {};
    catCountsMap.forEach((cat, count) {
      _categoryAvgRatings[cat] = (catTotalRatingMap[cat] ?? 0.0) / count;
    });

    if (_categoryCounts.isNotEmpty) {
      final sortedByUsage = _categoryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _mostUsedCategory = sortedByUsage.first.key;
    }

    if (_categoryAvgRatings.isNotEmpty) {
      final sortedByAvg = _categoryAvgRatings.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _highestRatedCategory = sortedByAvg.first.key;
      _lowestRatedCategory = sortedByAvg.last.key;
    }

    // 4. Rating Distribution (1★, 2★, 3★, 4★, 5★)
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var item in list) {
      final rounded = item.rating.round().clamp(1, 5);
      dist[rounded] = (dist[rounded] ?? 0) + 1;
    }
    _ratingDistribution = dist;

    // 5. Monthly Submissions (Past 6 months)
    final monthsMap = <String, int>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final mDate = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM').format(mDate);
      monthsMap[key] = 0;
    }

    for (var item in list) {
      final monthKey = DateFormat('MMM').format(item.createdAt);
      if (monthsMap.containsKey(monthKey)) {
        monthsMap[monthKey] = (monthsMap[monthKey] ?? 0) + 1;
      } else {
        monthsMap[monthKey] = 1;
      }
    }
    _monthlyCounts = monthsMap;

    // 6. Weekly Activity (Days of week)
    final weekDaysMap = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0
    };
    for (var item in list) {
      final dayKey = DateFormat('E').format(item.createdAt); // Mon, Tue, etc.
      if (weekDaysMap.containsKey(dayKey)) {
        weekDaysMap[dayKey] = (weekDaysMap[dayKey] ?? 0) + 1;
      }
    }
    _weeklyCounts = weekDaysMap;

    // 7. Most Active User
    final userCountsMap = <String, int>{};
    for (var item in list) {
      final name = item.submittedByName.isNotEmpty
          ? item.submittedByName
          : 'User ${item.submittedBy.substring(0, 4)}';
      userCountsMap[name] = (userCountsMap[name] ?? 0) + 1;
    }
    if (userCountsMap.isNotEmpty) {
      final sortedUsers = userCountsMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _mostActiveUser = sortedUsers.first.key;
    }

    // 8. Latest Feedbacks
    final sortedList = List<FeedbackModel>.from(list)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _latestFeedback = sortedList.take(5).toList();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
