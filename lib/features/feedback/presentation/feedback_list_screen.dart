import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/feedback_card.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/presentation/auth_provider.dart';
import 'feedback_provider.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context, FeedbackProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Feedbacks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.resetFilters();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Filter Dropdown
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: provider.selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    items: ['All', ...AppConstants.categories].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        provider.setCategoryFilter(val);
                        setModalState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role Filter
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['All', 'Student', 'Company'].map((r) {
                      final isSel = provider.selectedRole == r;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(r),
                          selected: isSel,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              provider.setRoleFilter(r);
                              setModalState(() {});
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal(BuildContext context, FeedbackProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final options = [
          AppConstants.sortNewest,
          AppConstants.sortOldest,
          AppConstants.sortHighestRating,
          AppConstants.sortLowestRating,
        ];

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Feedbacks By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSel = provider.sortBy == opt;
                return ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? AppColors.primary : null,
                    ),
                  ),
                  trailing: isSel
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    provider.setSortBy(opt);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Platform'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterModal(context, feedbackProvider, isDark),
          ),
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortModal(context, feedbackProvider, isDark),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkInputFill
                      : AppColors.lightInputFill,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => feedbackProvider.setSearchQuery(v),
                  decoration: InputDecoration(
                    hintText: 'Search title, category, submitter...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              feedbackProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),

            // Active Filters Banner
            if (feedbackProvider.selectedCategory != 'All' ||
                feedbackProvider.selectedRole != 'All' ||
                feedbackProvider.sortBy != 'Newest')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Text('Filters: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    if (feedbackProvider.selectedCategory != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Chip(
                          label: Text(feedbackProvider.selectedCategory, style: const TextStyle(fontSize: 11)),
                          onDeleted: () => feedbackProvider.setCategoryFilter('All'),
                        ),
                      ),
                    if (feedbackProvider.selectedRole != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Chip(
                          label: Text(feedbackProvider.selectedRole, style: const TextStyle(fontSize: 11)),
                          onDeleted: () => feedbackProvider.setRoleFilter('All'),
                        ),
                      ),
                  ],
                ),
              ),

            // List of Feedback Cards
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  feedbackProvider.listenToFeedbacks();
                },
                child: feedbackProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : feedbackProvider.feedbacks.isEmpty
                        ? EmptyStateWidget(
                            title: 'No Feedback Submissions',
                            description:
                                'Be the first to submit your feedback or try clearing active search filters.',
                            buttonText: 'Add Feedback',
                            onButtonPressed: () => context.push('/submit-feedback'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: feedbackProvider.feedbacks.length,
                            itemBuilder: (context, index) {
                              final item = feedbackProvider.feedbacks[index];
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/submit-feedback'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
