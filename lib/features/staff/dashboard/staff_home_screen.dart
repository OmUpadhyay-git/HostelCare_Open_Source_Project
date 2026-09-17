import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/components.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../core/constants/complaint_priority.dart';

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'My Assignments',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Assigned',
                    value: '4',
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.statusAssigned,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'In Progress',
                    value: '2',
                    icon: Icons.play_circle_outline,
                    iconColor: AppColors.statusInProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Active Tasks',
              trailing: TextButton(
                onPressed: null,
                child: Text('View All'),
              ),
            ),
            const SizedBox(height: 12),
            ComplaintCard(
              complaintNumber: 'HC-2026-00124',
              title: 'Bathroom water leakage',
              category: 'Plumbing',
              priority: ComplaintPriority.urgent,
              status: ComplaintStatus.inProgress,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ComplaintCard(
              complaintNumber: 'HC-2026-00120',
              title: 'AC not cooling',
              category: 'Air Conditioning',
              priority: ComplaintPriority.medium,
              status: ComplaintStatus.assigned,
              createdAt: DateTime.now().subtract(const Duration(hours: 4)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
