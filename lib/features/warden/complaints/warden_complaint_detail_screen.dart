import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../models/complaint.dart';
import '../../../providers/warden_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class WardenComplaintDetailScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const WardenComplaintDetailScreen({super.key, required this.complaintId});

  @override
  ConsumerState<WardenComplaintDetailScreen> createState() =>
      _WardenComplaintDetailScreenState();
}

class _WardenComplaintDetailScreenState
    extends ConsumerState<WardenComplaintDetailScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final complaintAsync = ref.watch(
      wardenComplaintDetailProvider(widget.complaintId),
    );
    final historyAsync = ref.watch(
      wardenComplaintHistoryProvider(widget.complaintId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: complaintAsync.when(
        data: (complaint) {
          if (complaint == null) {
            return const ErrorState(message: 'Complaint not found');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ComplaintHeader(complaint: complaint),
                const SizedBox(height: AppSpacing.lg),
                _ComplaintInfo(complaint: complaint),
                const SizedBox(height: AppSpacing.lg),
                _WardenActions(
                  complaint: complaint,
                  isProcessing: _isProcessing,
                  onAccept: () => _handleAccept(context, ref),
                  onReject: () => _showRejectDialog(context, ref),
                  onAssign: () => _showAssignDialog(context, ref),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ComplaintTimeline(historyAsync: historyAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Failed to load complaint details',
          actionLabel: 'Retry',
          onAction: () {
            ref.invalidate(wardenComplaintDetailProvider(widget.complaintId));
          },
        ),
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Accept Complaint',
      message: 'Are you sure you want to accept this complaint?',
      confirmLabel: 'Accept',
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isProcessing = true);

      try {
        await ref
            .read(wardenRepositoryProvider)
            .acceptComplaint(widget.complaintId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint accepted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(wardenComplaintDetailProvider(widget.complaintId));
          ref.invalidate(wardenComplaintHistoryProvider(widget.complaintId));
          ref.invalidate(wardenComplaintCountsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to accept complaint: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _showRejectDialog(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      setState(() => _isProcessing = true);

      try {
        await ref
            .read(wardenRepositoryProvider)
            .rejectComplaint(widget.complaintId, reasonController.text.trim());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint rejected'),
              backgroundColor: AppColors.warning,
            ),
          );
          ref.invalidate(wardenComplaintDetailProvider(widget.complaintId));
          ref.invalidate(wardenComplaintHistoryProvider(widget.complaintId));
          ref.invalidate(wardenComplaintCountsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to reject complaint: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _showAssignDialog(BuildContext context, WidgetRef ref) async {
    final staffAsync = ref.read(wardenAvailableStaffProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Assign Staff'),
        content: SizedBox(
          width: double.maxFinite,
          child: staffAsync.when(
            data: (staffList) {
              if (staffList.isEmpty) {
                return const Text('No staff members available for assignment.');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final staff = staffList[index];
                  return ListTile(
                    title: Text(staff.displayName),
                    subtitle: Text(staff.departmentDisplay),
                    leading: CircleAvatar(
                      child: Text(staff.displayName[0].toUpperCase()),
                    ),
                    onTap: () => Navigator.pop(dialogContext, staff.id),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Failed to load staff members'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      setState(() => _isProcessing = true);

      try {
        await ref
            .read(wardenRepositoryProvider)
            .assignComplaint(widget.complaintId, result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Staff assigned successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(wardenComplaintDetailProvider(widget.complaintId));
          ref.invalidate(wardenComplaintHistoryProvider(widget.complaintId));
          ref.invalidate(wardenComplaintCountsProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to assign staff: ${e.toString().replaceAll('Exception: ', '')}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
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
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
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
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (complaint.categoryName != null) ...[
                CategoryBadge(category: complaint.categoryName!),
                const SizedBox(width: 8),
              ],
              PriorityBadge(priority: complaint.priority, showIcon: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplaintInfo extends StatelessWidget {
  final Complaint complaint;

  const _ComplaintInfo({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complaint Information',
            style: AppTextStyles.titleSmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Student',
            value:
                complaint.studentName ?? complaint.studentIdentifier ?? 'N/A',
          ),
          _InfoRow(
            label: 'Location',
            value: complaint.locationDisplay.isNotEmpty
                ? complaint.locationDisplay
                : 'N/A',
          ),
          if (complaint.description != null &&
              complaint.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Description',
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              complaint.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          if (complaint.staffName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Assigned Staff', value: complaint.staffName!),
          ],
          if (complaint.resolutionRemark != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Resolution', value: complaint.resolutionRemark!),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

class _WardenActions extends StatelessWidget {
  final Complaint complaint;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onAssign;

  const _WardenActions({
    required this.complaint,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    if (isProcessing) {
      return const AppCard(
        padding: EdgeInsets.all(AppSpacing.base),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (complaint.status == ComplaintStatus.pending) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warden Actions',
              style: AppTextStyles.titleSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: 'Accept',
                    icon: Icons.check,
                    onPressed: onAccept,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton.destructive(
                    label: 'Reject',
                    icon: Icons.close,
                    onPressed: onReject,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (complaint.status == ComplaintStatus.accepted) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warden Actions',
              style: AppTextStyles.titleSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton.primary(
              label: 'Assign Staff',
              icon: Icons.person_add,
              onPressed: onAssign,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _ComplaintTimeline extends StatelessWidget {
  final AsyncValue<List<dynamic>> historyAsync;

  const _ComplaintTimeline({required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: AppTextStyles.titleSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return const Text('No history available');
              }

              return Column(
                children: history.map((entry) {
                  final eventType = TimelineActionTypeExtension.fromStatus(
                    entry.newStatus,
                  );
                  return TimelineItem(
                    event: TimelineEvent(
                      actionType: eventType,
                      performerName: entry.changedByName,
                      performerRole: entry.changedByRole?.label,
                      remark: entry.remark,
                      timestamp: entry.createdAt,
                    ),
                    isFirst: entry == history.first,
                    isLast: entry == history.last,
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Failed to load timeline'),
          ),
        ],
      ),
    );
  }
}
