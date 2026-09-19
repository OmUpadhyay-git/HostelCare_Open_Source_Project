import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../core/constants/complaint_priority.dart';
import '../../../models/complaint.dart';
import '../../../models/complaint_history.dart';
import '../../../providers/complaint_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class ComplaintDetailScreen extends ConsumerWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintAsync = ref.watch(complaintDetailProvider(complaintId));
    final historyAsync = ref.watch(complaintHistoryProvider(complaintId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: complaintAsync.when(
        data: (complaint) {
          if (complaint == null) {
            return const ErrorState(
              message: 'Complaint not found',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(complaintDetailProvider(complaintId));
              ref.invalidate(complaintHistoryProvider(complaintId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint header
                  _ComplaintHeader(complaint: complaint),
                  const SizedBox(height: AppSpacing.lg),

                  // Status and priority
                  _StatusPriorityRow(complaint: complaint),
                  const SizedBox(height: AppSpacing.lg),

                  // Description
                  if (complaint.description != null &&
                      complaint.description!.isNotEmpty) ...[
                    SectionHeader(title: 'Description'),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Text(
                        complaint.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Location info
                  SectionHeader(title: 'Location'),
                  const SizedBox(height: AppSpacing.sm),
                  _LocationInfo(complaint: complaint),
                  const SizedBox(height: AppSpacing.lg),

                  // Assignment info
                  if (complaint.wardenName != null ||
                      complaint.staffName != null) ...[
                    SectionHeader(title: 'Assigned To'),
                    const SizedBox(height: AppSpacing.sm),
                    _AssignmentInfo(complaint: complaint),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Resolution info
                  if (complaint.status == ComplaintStatus.resolved ||
                      complaint.status == ComplaintStatus.verified ||
                      complaint.status == ComplaintStatus.closed) ...[
                    SectionHeader(title: 'Resolution'),
                    const SizedBox(height: AppSpacing.sm),
                    _ResolutionInfo(complaint: complaint),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Timeline
                  SectionHeader(title: 'Timeline'),
                  const SizedBox(height: AppSpacing.sm),
                  historyAsync.when(
                    data: (history) {
                      if (history.isEmpty) {
                        return const AppCard(
                          padding: EdgeInsets.all(AppSpacing.base),
                          child: Text('No history available'),
                        );
                      }

                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Timeline(
                          events: history.map((h) {
                            return TimelineEvent(
                              actionType: _mapActionType(h),
                              performerName: h.changedByName,
                              performerRole: _mapRoleLabel(h.changedByRole),
                              remark: h.remark,
                              timestamp: h.createdAt,
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SkeletonLoader(
                      width: double.infinity,
                      height: 200,
                    ),
                    error: (error, _) => const AppCard(
                      padding: EdgeInsets.all(AppSpacing.base),
                      child: Text('Failed to load timeline'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons based on status
                  _ActionButtons(
                    complaint: complaint,
                    onAction: () {
                      ref.invalidate(complaintDetailProvider(complaintId));
                      ref.invalidate(complaintHistoryProvider(complaintId));
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Failed to load complaint details',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(complaintDetailProvider(complaintId)),
        ),
      ),
    );
  }

  TimelineActionType _mapActionType(ComplaintHistory history) {
    if (history.newStatus != null) {
      return TimelineActionTypeExtension.fromStatus(history.newStatus!);
    }

    final action = history.action.toLowerCase();
    if (action.contains('comment')) return TimelineActionType.comment;
    if (action.contains('image')) return TimelineActionType.progressUpdated;
    return TimelineActionType.comment;
  }

  String? _mapRoleLabel(String? role) {
    return switch (role) {
      'student' => 'Student',
      'warden' => 'Warden',
      'staff' => 'Staff',
      'admin' => 'Admin',
      _ => null,
    };
  }
}

class _ComplaintHeader extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintHeader({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.complaintNumber,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              ComplaintStatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            complaint.title,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (complaint.categoryName != null) ...[
                CategoryBadge(category: complaint.categoryName!),
                const SizedBox(width: AppSpacing.sm),
              ],
              PriorityBadge(priority: complaint.priority, showIcon: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Created: ${DateFormat('dd MMM yyyy, HH:mm').format(complaint.createdAt)}',
            style: AppTextStyles.captionSmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPriorityRow extends StatelessWidget {
  final Complaint complaint;

  const _StatusPriorityRow({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            label: 'Status',
            value: complaint.status.label,
            color: complaint.status.color,
            icon: complaint.status.icon,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _InfoTile(
            label: 'Priority',
            value: complaint.priority.label,
            color: complaint.priority.color,
            icon: complaint.priority.icon,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
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

class _LocationInfo extends StatelessWidget {
  final Complaint complaint;

  const _LocationInfo({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = complaint.locationDisplay;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              location.isNotEmpty ? location : 'Location not available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentInfo extends StatelessWidget {
  final Complaint complaint;

  const _AssignmentInfo({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (complaint.wardenName != null)
            _AssignmentRow(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Warden',
              name: complaint.wardenName!,
            ),
          if (complaint.wardenName != null && complaint.staffName != null)
            const SizedBox(height: AppSpacing.sm),
          if (complaint.staffName != null)
            _AssignmentRow(
              icon: Icons.build_outlined,
              label: 'Assigned Staff',
              name: complaint.staffName!,
            ),
        ],
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;

  const _AssignmentRow({
    required this.icon,
    required this.label,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResolutionInfo extends StatelessWidget {
  final Complaint complaint;

  const _ResolutionInfo({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (complaint.resolvedAt != null)
            Text(
              'Resolved: ${DateFormat('dd MMM yyyy, HH:mm').format(complaint.resolvedAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          if (complaint.resolutionRemark != null &&
              complaint.resolutionRemark!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              complaint.resolutionRemark!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final Complaint complaint;
  final VoidCallback onAction;

  const _ActionButtons({
    required this.complaint,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show action buttons based on complaint status
    if (complaint.status == ComplaintStatus.resolved) {
      return Row(
        children: [
          Expanded(
            child: AppButton.destructive(
              label: 'Not Fixed',
              icon: Icons.close,
              onPressed: () => _showReopenDialog(context, ref),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton.primary(
              label: 'Verify Fix',
              icon: Icons.check,
              onPressed: () => _verifyComplaint(context, ref, verified: true),
            ),
          ),
        ],
      );
    }

    if (complaint.status == ComplaintStatus.pending &&
        !complaint.status.isTerminal) {
      return AppButton.destructive(
        label: 'Cancel Complaint',
        icon: Icons.cancel_outlined,
        onPressed: () => _showCancelDialog(context, ref),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _verifyComplaint(
    BuildContext context,
    WidgetRef ref, {
    required bool verified,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: verified ? 'Verify Resolution' : 'Report Issue',
      message: verified
          ? 'Are you sure the issue has been resolved? This will close the complaint.'
          : 'The issue is not fixed. This will reopen the complaint.',
      confirmLabel: verified ? 'Verify' : 'Report',
      isDestructive: !verified,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(complaintRepositoryProvider).verifyComplaint(
              complaint.id,
              verified: verified,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verified
                  ? 'Complaint verified and closed'
                  : 'Complaint reopened for further work'),
              backgroundColor: verified ? AppColors.success : AppColors.warning,
            ),
          );
          onAction();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Action failed: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showReopenDialog(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reopen Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe why the issue is not resolved:'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for reopening...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Reopen'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      try {
        await ref.read(complaintRepositoryProvider).reopenComplaint(
              complaint.id,
              reasonController.text.trim(),
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint reopened'),
              backgroundColor: AppColors.warning,
            ),
          );
          onAction();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reopen: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showCancelDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Cancel Complaint',
      message: 'Are you sure you want to cancel this complaint? This action cannot be undone.',
      confirmLabel: 'Cancel Complaint',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(complaintRepositoryProvider).cancelComplaint(complaint.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint cancelled'),
              backgroundColor: AppColors.statusNegative,
            ),
          );
          onAction();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
