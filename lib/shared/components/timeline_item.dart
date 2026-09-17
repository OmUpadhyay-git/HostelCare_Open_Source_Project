import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/complaint_status.dart';

enum TimelineActionType {
  created,
  accepted,
  assigned,
  workStarted,
  progressUpdated,
  resolved,
  verified,
  closed,
  reopened,
  rejected,
  cancelled,
  onHold,
  comment,
}

extension TimelineActionTypeExtension on TimelineActionType {
  String get label {
    return switch (this) {
      TimelineActionType.created => 'Complaint Created',
      TimelineActionType.accepted => 'Complaint Accepted',
      TimelineActionType.assigned => 'Complaint Assigned',
      TimelineActionType.workStarted => 'Work Started',
      TimelineActionType.progressUpdated => 'Progress Updated',
      TimelineActionType.resolved => 'Resolved',
      TimelineActionType.verified => 'Verified',
      TimelineActionType.closed => 'Closed',
      TimelineActionType.reopened => 'Reopened',
      TimelineActionType.rejected => 'Rejected',
      TimelineActionType.cancelled => 'Cancelled',
      TimelineActionType.onHold => 'On Hold',
      TimelineActionType.comment => 'Comment',
    };
  }

  IconData get icon {
    return switch (this) {
      TimelineActionType.created => Icons.add_circle_outline,
      TimelineActionType.accepted => Icons.check_circle_outline,
      TimelineActionType.assigned => Icons.person_add_outlined,
      TimelineActionType.workStarted => Icons.play_circle_outline,
      TimelineActionType.progressUpdated => Icons.update,
      TimelineActionType.resolved => Icons.check_circle,
      TimelineActionType.verified => Icons.verified,
      TimelineActionType.closed => Icons.archive,
      TimelineActionType.reopened => Icons.replay,
      TimelineActionType.rejected => Icons.cancel_outlined,
      TimelineActionType.cancelled => Icons.close,
      TimelineActionType.onHold => Icons.pause_circle_outline,
      TimelineActionType.comment => Icons.comment_outlined,
    };
  }

  Color get color {
    return switch (this) {
      TimelineActionType.created => AppColors.statusPending,
      TimelineActionType.accepted => AppColors.statusAccepted,
      TimelineActionType.assigned => AppColors.statusAssigned,
      TimelineActionType.workStarted => AppColors.statusInProgress,
      TimelineActionType.progressUpdated => AppColors.statusInProgress,
      TimelineActionType.resolved => AppColors.statusResolved,
      TimelineActionType.verified => AppColors.statusVerified,
      TimelineActionType.closed => AppColors.statusClosed,
      TimelineActionType.reopened => AppColors.statusReopened,
      TimelineActionType.rejected => AppColors.statusNegative,
      TimelineActionType.cancelled => AppColors.statusNegative,
      TimelineActionType.onHold => AppColors.statusOnHold,
      TimelineActionType.comment => AppColors.primary,
    };
  }

  static TimelineActionType fromStatus(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.pending => TimelineActionType.created,
      ComplaintStatus.accepted => TimelineActionType.accepted,
      ComplaintStatus.assigned => TimelineActionType.assigned,
      ComplaintStatus.inProgress => TimelineActionType.workStarted,
      ComplaintStatus.resolved => TimelineActionType.resolved,
      ComplaintStatus.verified => TimelineActionType.verified,
      ComplaintStatus.closed => TimelineActionType.closed,
      ComplaintStatus.rejected => TimelineActionType.rejected,
      ComplaintStatus.cancelled => TimelineActionType.cancelled,
      ComplaintStatus.reopened => TimelineActionType.reopened,
      ComplaintStatus.onHold => TimelineActionType.onHold,
    };
  }
}

class TimelineEvent {
  final TimelineActionType actionType;
  final String? performerName;
  final String? performerRole;
  final String? remark;
  final DateTime timestamp;

  const TimelineEvent({
    required this.actionType,
    this.performerName,
    this.performerRole,
    this.remark,
    required this.timestamp,
  });
}

class TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.event,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: event.actionType.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event.actionType.icon,
                    size: 14,
                    color: event.actionType.color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.actionType.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (event.performerName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${event.performerName}${event.performerRole != null ? ' • ${event.performerRole}' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  if (event.remark != null && event.remark!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.remark!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(event.timestamp),
                    style: AppTextStyles.captionSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
    }
  }
}

class Timeline extends StatelessWidget {
  final List<TimelineEvent> events;

  const Timeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(
        events.length,
        (index) => TimelineItem(
          event: events[index],
          isFirst: index == 0,
          isLast: index == events.length - 1,
        ),
      ),
    );
  }
}
