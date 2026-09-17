import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/components/components.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'System Overview',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Total Complaints',
                    value: '156',
                    icon: Icons.report_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Active',
                    value: '42',
                    icon: Icons.pending_outlined,
                    iconColor: AppColors.statusPending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    title: 'Resolved',
                    value: '98',
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.statusResolved,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    title: 'Overdue',
                    value: '7',
                    icon: Icons.warning_amber,
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Quick Actions',
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Manage Users',
              icon: Icons.people_outline,
              type: AppButtonType.outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Manage Hostels',
              icon: Icons.business_outlined,
              type: AppButtonType.outlined,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'View Reports',
              icon: Icons.analytics_outlined,
              type: AppButtonType.outlined,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
