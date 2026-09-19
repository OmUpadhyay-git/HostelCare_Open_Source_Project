import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final studentRecord = ref.watch(studentRecordProvider);
    final complaintCounts = ref.watch(complaintCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentRecordProvider);
          ref.invalidate(complaintCountsProvider);
          ref.read(complaintListProvider.notifier).loadComplaints(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _WelcomeSection(
                profile: profile,
                studentRecord: studentRecord,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Complaint summary stats
              _ComplaintStats(
                complaintCounts: complaintCounts,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick actions
              SectionHeader(
                title: 'Quick Actions',
                trailing: TextButton(
                  onPressed: () => context.push('/student/complaints'),
                  child: const Text('View All'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton.primary(
                      label: 'Raise Complaint',
                      icon: Icons.add,
                      onPressed: () => context.push('/student/complaints/new'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Recent complaints
              SectionHeader(
                title: 'Recent Complaints',
                trailing: TextButton(
                  onPressed: () => context.push('/student/complaints'),
                  child: const Text('View All'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _RecentComplaints(
                complaintList: ref.watch(complaintListProvider),
                onComplaintTap: (id) => context.push('/student/complaints/$id'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final dynamic profile;
  final AsyncValue<dynamic> studentRecord;

  const _WelcomeSection({
    required this.profile,
    required this.studentRecord,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final studentName = profile?.fullName ?? 'Student';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.school_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $studentName',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    studentRecord.when(
                      data: (record) => record != null
                          ? Text(
                              record.locationDisplay,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          studentRecord.when(
            data: (record) => record != null
                ? Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _InfoChip(
                        label: 'Student ID',
                        value: record.studentIdentifier,
                        icon: Icons.badge_outlined,
                      ),
                      _InfoChip(
                        label: 'Hostel',
                        value: record.hostelDisplay,
                        icon: Icons.home_outlined,
                      ),
                      _InfoChip(
                        label: 'Room',
                        value: record.room.roomNumber,
                        icon: Icons.meeting_room_outlined,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(height: 20),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComplaintStats extends StatelessWidget {
  final AsyncValue<Map<String, int>> complaintCounts;

  const _ComplaintStats({required this.complaintCounts});

  @override
  Widget build(BuildContext context) {
    return complaintCounts.when(
      data: (counts) {
        final total = counts.values.fold<int>(0, (sum, count) => sum + count);
        final pending = counts['pending'] ?? 0;
        final inProgress = (counts['accepted'] ?? 0) +
            (counts['assigned'] ?? 0) +
            (counts['in_progress'] ?? 0);
        final resolved = counts['resolved'] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Complaint Summary'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Total',
                    value: '$total',
                    icon: Icons.report_outlined,
                    onTap: () => context.push('/student/complaints'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Pending',
                    value: '$pending',
                    icon: Icons.schedule,
                    iconColor: AppColors.statusPending,
                    onTap: () => context.push('/student/complaints'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'In Progress',
                    value: '$inProgress',
                    icon: Icons.play_circle_outline,
                    iconColor: AppColors.statusInProgress,
                    onTap: () => context.push('/student/complaints'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Resolved',
                    value: '$resolved',
                    icon: Icons.check_circle,
                    iconColor: AppColors.statusResolved,
                    onTap: () => context.push('/student/complaints'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const DashboardSkeletonLoader(),
      error: (error, _) => ErrorState(
        message: 'Failed to load complaint data',
        actionLabel: 'Retry',
        onAction: () {},
      ),
    );
  }
}

class _RecentComplaints extends StatelessWidget {
  final AsyncValue<List<dynamic>> complaintList;
  final ValueChanged<String> onComplaintTap;

  const _RecentComplaints({
    required this.complaintList,
    required this.onComplaintTap,
  });

  @override
  Widget build(BuildContext context) {
    return complaintList.when(
      data: (complaints) {
        if (complaints.isEmpty) {
          return EmptyState(
            icon: Icons.report_outlined,
            title: 'No complaints yet',
            message: 'You haven\'t raised any complaints. Tap below to get started.',
            actionLabel: 'Raise Complaint',
            onAction: () => context.push('/student/complaints/new'),
          );
        }

        // Show only first 3 recent complaints
        final recentComplaints = complaints.take(3).toList();

        return Column(
          children: recentComplaints.map((complaint) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ComplaintCard(
                complaintNumber: complaint.complaintNumber,
                title: complaint.title,
                category: complaint.categoryName,
                priority: complaint.priority,
                status: complaint.status,
                createdAt: complaint.createdAt,
                onTap: () => onComplaintTap(complaint.id),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const ListSkeletonLoader(itemCount: 3),
      error: (error, _) => ErrorState(
        message: 'Failed to load recent complaints',
        actionLabel: 'Retry',
        onAction: () {},
      ),
    );
  }
}
