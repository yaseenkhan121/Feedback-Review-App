import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/feedback_card.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../feedback/presentation/feedback_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'User Experience',
    'Bug Report',
    'Course Content',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    final currentUser = authProvider.currentUser;
    final results = feedbackProvider.feedbacks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Platform'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkInputFill
                      : AppColors.lightInputFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) {
                    feedbackProvider.setSearchQuery(val);
                  },
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search feedback title, category, author...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              feedbackProvider.setSearchQuery('');
                              setState(() {});
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

            // Category Chips horizontal slider
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: AppConstants.categories.length,
                itemBuilder: (ctx, idx) {
                  final cat = AppConstants.categories[idx];
                  final isSelected = feedbackProvider.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CategoryChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          feedbackProvider.setCategoryFilter('All');
                        } else {
                          feedbackProvider.setCategoryFilter(cat);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Recent Searches (if query empty)
            if (_searchController.text.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(
                  spacing: 8,
                  children: _recentSearches.map((term) {
                    return ActionChip(
                      label: Text(term, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.history_rounded, size: 14),
                      backgroundColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightInputFill,
                      onPressed: () {
                        _searchController.text = term;
                        feedbackProvider.setSearchQuery(term);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Search Results List
            Expanded(
              child: results.isEmpty
                  ? EmptyStateWidget(
                      title: 'No Matching Results',
                      description:
                          'We could not find any feedback matching "${_searchController.text}".',
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: results.length,
                      itemBuilder: (ctx, idx) {
                        final item = results[idx];
                        return FeedbackCard(
                          feedback: item,
                          currentUserId: currentUser?.uid,
                          onTap: () => context.push('/feedback-details/${item.feedbackId}'),
                          onEdit: () => context.push('/edit-feedback/${item.feedbackId}'),
                          onDelete: () => feedbackProvider.deleteFeedback(
                            item.feedbackId,
                            currentUser!.uid,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
