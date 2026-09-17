import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/components.dart';
import '../../../core/constants/complaint_status.dart';
import '../../../core/constants/complaint_priority.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Quick Actions',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'My Complaints',
                    value: '3',
                    icon: Icons.report_outlined,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Active',
                    value: '1',
                    icon: Icons.pending_outlined,
                    iconColor: AppColors.statusPending,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Recent Complaints',
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
              priority: ComplaintPriority.high,
              status: ComplaintStatus.inProgress,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ComplaintCard(
              complaintNumber: 'HC-2026-00119',
              title: 'WiFi not working in room',
              category: 'Wi-Fi/Internet',
              priority: ComplaintPriority.medium,
              status: ComplaintStatus.pending,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: 'Raise Complaint',
              icon: Icons.add,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
