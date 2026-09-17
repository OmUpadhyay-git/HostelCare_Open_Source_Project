import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/components.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../core/constants/complaint_priority.dart';

class WardenHomeScreen extends StatelessWidget {
  const WardenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Overview',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Pending',
                    value: '5',
                    icon: Icons.schedule,
                    iconColor: AppColors.statusPending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'In Progress',
                    value: '8',
                    icon: Icons.play_circle_outline,
                    iconColor: AppColors.statusInProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Overdue',
                    value: '2',
                    icon: Icons.warning_amber,
                    iconColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Resolved Today',
                    value: '3',
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.statusResolved,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Complaint Queue',
              trailing: TextButton(
                onPressed: null,
                child: Text('View All'),
              ),
            ),
            const SizedBox(height: 12),
            ComplaintCard(
              complaintNumber: 'HC-2026-00125',
              title: 'Broken window in Room 204',
              category: 'Room Maintenance',
              priority: ComplaintPriority.high,
              status: ComplaintStatus.pending,
              createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ComplaintCard(
              complaintNumber: 'HC-2026-00124',
              title: 'Bathroom water leakage',
              category: 'Plumbing',
              priority: ComplaintPriority.urgent,
              status: ComplaintStatus.assigned,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
