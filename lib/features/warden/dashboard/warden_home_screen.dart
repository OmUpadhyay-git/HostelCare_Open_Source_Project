import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/warden_provider.dart';
import '../../../shared/components/components.dart';
import '../../../shared/widgets/widgets.dart';

class WardenHomeScreen extends ConsumerWidget {
  const WardenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final wardenRecord = ref.watch(wardenRecordProvider);
    final complaintCounts = ref.watch(wardenComplaintCountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Dashboard'),
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
          ref.invalidate(wardenRecordProvider);
          ref.invalidate(wardenComplaintCountsProvider);
          ref.read(wardenComplaintListProvider.notifier).loadComplaints(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeSection(
                profile: profile,
                wardenRecord: wardenRecord,
              ),
              const SizedBox(height: AppSpacing.lg),
              _ComplaintStats(
                complaintCounts: complaintCounts,
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Quick Actions',
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppButton.primary(
                      label: 'View Complaints',
                      icon: Icons.list_alt,
                      onPressed: () => context.push('/warden/complaints'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Recent Complaints',
                trailing: TextButton(
                  onPressed: () => context.push('/warden/complaints'),
                  child: const Text('View All'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _RecentComplaints(
                complaintList: ref.watch(wardenComplaintListProvider),
                onComplaintTap: (id) => context.push('/warden/complaints/$id'),
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
  final AsyncValue<dynamic> wardenRecord;

  const _WelcomeSection({
    required this.profile,
    required this.wardenRecord,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final wardenName = profile?.fullName ?? 'Warden';

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
                  Icons.admin_panel_settings_outlined,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $wardenName',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    wardenRecord.when(
                      data: (record) => record != null
                          ? Text(
                              'Hostel: ${record.hostelDisplay}',
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
        final accepted = counts['accepted'] ?? 0;
        final assigned = counts['assigned'] ?? 0;
        final inProgress = counts['in_progress'] ?? 0;
        final resolved = counts['resolved'] ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Complaint Overview'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Total',
                    value: '$total',
                    icon: Icons.report_outlined,
                    onTap: () => context.push('/warden/complaints'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Pending',
                    value: '$pending',
                    icon: Icons.schedule,
                    iconColor: AppColors.statusPending,
                    onTap: () => context.push('/warden/complaints'),
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
                    value: '${accepted + assigned + inProgress}',
                    icon: Icons.play_circle_outline,
                    iconColor: AppColors.statusInProgress,
                    onTap: () => context.push('/warden/complaints'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Resolved',
                    value: '$resolved',
                    icon: Icons.check_circle,
                    iconColor: AppColors.statusResolved,
                    onTap: () => context.push('/warden/complaints'),
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
            title: 'No complaints',
            message: 'No complaints have been submitted to your hostel yet.',
          );
        }

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
