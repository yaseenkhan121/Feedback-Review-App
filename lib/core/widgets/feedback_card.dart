import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../models/feedback_model.dart';
import '../../models/user_model.dart';
import '../constants/app_colors.dart';
import '../utils/date_formatter.dart';
import 'category_chip.dart';
import 'rating_widget.dart';
import 'status_badge.dart';

class FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  final String? currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.currentUserId,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = currentUserId != null && currentUserId == feedback.submittedBy;

    final isStudentRole = feedback.role.toLowerCase() == 'student';
    final roleColor = isStudentRole
        ? AppColors.studentRoleColor
        : AppColors.companyRoleColor;

    return StreamBuilder<UserModel?>(
      stream: ProfileRepository().getProfileStream(feedback.submittedBy),
      builder: (context, snapshot) {
        final authorProfile = snapshot.data;
        final authorName = authorProfile?.name.isNotEmpty == true
            ? authorProfile!.name
            : (feedback.submittedByName.isNotEmpty ? feedback.submittedByName : 'User');
        final authorPhotoUrl = authorProfile?.photoUrl ?? '';
        final avatarInitial = authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Row: User Info & Status
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: roleColor.withAlpha(40),
                          child: authorPhotoUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: authorPhotoUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                    errorWidget: (context, url, error) => Text(
                                      avatarInitial,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: roleColor,
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  avatarInitial,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: roleColor,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      authorName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: roleColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      feedback.role,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: roleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatRelative(feedback.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: feedback.status),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title & Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            feedback.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Description preview
                    Text(
                      feedback.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category & Star Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryChip(label: feedback.category),
                        RatingWidget(
                          rating: feedback.rating,
                          isInteractive: false,
                          iconSize: 18,
                        ),
                      ],
                    ),

                    // Owner Actions (Edit / Delete) if user owns this feedback
                    if (isOwner) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit', style: TextStyle(fontSize: 13)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Delete', style: TextStyle(fontSize: 13)),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
