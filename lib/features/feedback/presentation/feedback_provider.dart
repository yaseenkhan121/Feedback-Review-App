import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/feedback_model.dart';
import '../data/feedback_repository.dart';

class FeedbackProvider extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository();

  String _selectedCategory = 'All';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';
  String _sortBy = 'Newest';
  String _searchQuery = '';

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<FeedbackModel>>? _subscription;

  String get selectedCategory => _selectedCategory;
  String get selectedRole => _selectedRole;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;
  String get searchQuery => _searchQuery;

  List<FeedbackModel> get feedbacks => _filteredFeedbacks();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FeedbackProvider() {
    listenToFeedbacks();
  }

  void listenToFeedbacks() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository
        .getFeedbacksStream(
          category: _selectedCategory,
          role: _selectedRole,
          status: _selectedStatus,
          sortBy: _sortBy,
        )
        .listen(
      (data) {
        _feedbacks = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load feedbacks: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<FeedbackModel> _filteredFeedbacks() {
    if (_searchQuery.trim().isEmpty) {
      return _feedbacks;
    }
    final q = _searchQuery.toLowerCase().trim();
    return _feedbacks.where((f) {
      final titleMatch = f.title.toLowerCase().contains(q);
      final catMatch = f.category.toLowerCase().contains(q);
      final userMatch = f.submittedByName.toLowerCase().contains(q);
      final descMatch = f.description.toLowerCase().contains(q);
      return titleMatch || catMatch || userMatch || descMatch;
    }).toList();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    listenToFeedbacks();
  }

  void setRoleFilter(String role) {
    _selectedRole = role;
    listenToFeedbacks();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    listenToFeedbacks();
  }

  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    listenToFeedbacks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _selectedRole = 'All';
    _selectedStatus = 'All';
    _sortBy = 'Newest';
    _searchQuery = '';
    listenToFeedbacks();
  }

  Future<bool> createFeedback({
    required String title,
    required String description,
    required double rating,
    required String category,
    required String submittedBy,
    required String submittedByName,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newFeedback = FeedbackModel(
        feedbackId: '',
        title: title.trim(),
        description: description.trim(),
        rating: rating,
        category: category,
        submittedBy: submittedBy,
        submittedByName: submittedByName,
        role: role,
        status: 'Pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createFeedback(newFeedback);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateFeedback(FeedbackModel feedback) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateFeedback(feedback);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteFeedback(String feedbackId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteFeedback(feedbackId, userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
