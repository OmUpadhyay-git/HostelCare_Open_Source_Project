import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: color,
        ),
      ),
    );
  }
}

class ComplaintStatusBadge extends StatelessWidget {
  final String status;

  const ComplaintStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo(status);
    return StatusBadge(label: label, color: color);
  }

  (String, Color) _getStatusInfo(String status) {
    return switch (status.toUpperCase()) {
      'PENDING' => ('PENDING', AppColors.statusPending),
      'ACCEPTED' => ('ACCEPTED', AppColors.statusAccepted),
      'ASSIGNED' => ('ASSIGNED', AppColors.statusAssigned),
      'IN_PROGRESS' => ('IN PROGRESS', AppColors.statusInProgress),
      'RESOLVED' => ('RESOLVED', AppColors.statusResolved),
      'VERIFIED' => ('VERIFIED', AppColors.statusVerified),
      'CLOSED' => ('CLOSED', AppColors.statusClosed),
      'REJECTED' => ('REJECTED', AppColors.statusNegative),
      'CANCELLED' => ('CANCELLED', AppColors.statusNegative),
      'REOPENED' => ('REOPENED', AppColors.statusReopened),
      'ON_HOLD' => ('ON HOLD', AppColors.statusOnHold),
      _ => (status.toUpperCase(), AppColors.statusClosed),
    };
  }
}
