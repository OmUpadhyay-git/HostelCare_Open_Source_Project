import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/complaint_status.dart';
import '../../core/constants/complaint_priority.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final String complaintNumber;
  final String title;
  final String? category;
  final ComplaintPriority? priority;
  final ComplaintStatus status;
  final DateTime createdAt;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaintNumber,
    required this.title,
    this.category,
    this.priority,
    required this.status,
    required this.createdAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaintNumber,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  ComplaintStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (category != null) ...[
                    CategoryBadge(category: category!),
                    const SizedBox(width: 8),
                  ],
                  if (priority != null) ...[
                    PriorityBadge(priority: priority!),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(createdAt),
                style: AppTextStyles.captionSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}
