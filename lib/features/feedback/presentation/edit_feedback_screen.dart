import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/rating_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../auth/presentation/auth_provider.dart';
import 'feedback_provider.dart';

class EditFeedbackScreen extends StatefulWidget {
  final String feedbackId;

  const EditFeedbackScreen({super.key, required this.feedbackId});

  @override
  State<EditFeedbackScreen> createState() => _EditFeedbackScreenState();
}

class _EditFeedbackScreenState extends State<EditFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String _selectedCategory = AppConstants.categories.first;
  double _rating = 5.0;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      final list = feedbackProvider.feedbacks;
      final target = list.firstWhere(
        (f) => f.feedbackId == widget.feedbackId,
        orElse: () => list.first,
      );

      _titleController.text = target.title;
      _descriptionController.text = target.description;
      _selectedCategory = target.category;
      _rating = target.rating;
      _isLoaded = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final target = feedbackProvider.feedbacks.firstWhere(
      (f) => f.feedbackId == widget.feedbackId,
    );

    final updated = target.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      rating: _rating,
      updatedAt: DateTime.now(),
    );

    final success = await feedbackProvider.updateFeedback(updated);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (feedbackProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedbackProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Card Container
                Container(
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
                      CustomTextField(
                        label: 'Title',
                        controller: _titleController,
                        validator: Validators.validateTitle,
                      ),
                      const SizedBox(height: 18),

                      CustomTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: 4,
                        validator: Validators.validateDescription,
                      ),
                      const SizedBox(height: 18),

                      // Category Dropdown
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: AppConstants.categories.contains(_selectedCategory)
                            ? _selectedCategory
                            : AppConstants.categories.first,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkInputFill
                              : AppColors.lightInputFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: AppConstants.categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Rating Selector
                      Text(
                        'Rating',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: RatingWidget(
                          rating: _rating,
                          iconSize: 36,
                          onRatingChanged: (val) {
                            setState(() {
                              _rating = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons
                CustomButton(
                  text: 'Update Feedback',
                  icon: Icons.save_rounded,
                  isLoading: feedbackProvider.isLoading,
                  onPressed: _handleUpdate,
                ),
                const SizedBox(height: 12),

                // Delete & Cancel Row
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Delete',
                        isOutlined: true,
                        backgroundColor: AppColors.error,
                        textColor: AppColors.error,
                        onPressed: () {
                          ConfirmationDialog.show(
                            context,
                            title: 'Delete Feedback',
                            message: 'Are you sure you want to delete this feedback?',
                            confirmText: 'Delete',
                            isDangerous: true,
                            onConfirm: () async {
                              final ok = await feedbackProvider.deleteFeedback(
                                widget.feedbackId,
                                currentUser!.uid,
                              );
                              if (ok && mounted) {
                                context.pop();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        isOutlined: true,
                        textColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
