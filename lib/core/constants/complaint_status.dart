import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum ComplaintStatus {
  pending,
  accepted,
  assigned,
  inProgress,
  resolved,
  verified,
  closed,
  rejected,
  cancelled,
  reopened,
  onHold,
}

extension ComplaintStatusExtension on ComplaintStatus {
  String get label {
    return switch (this) {
      ComplaintStatus.pending => 'PENDING',
      ComplaintStatus.accepted => 'ACCEPTED',
      ComplaintStatus.assigned => 'ASSIGNED',
      ComplaintStatus.inProgress => 'IN PROGRESS',
      ComplaintStatus.resolved => 'RESOLVED',
      ComplaintStatus.verified => 'VERIFIED',
      ComplaintStatus.closed => 'CLOSED',
      ComplaintStatus.rejected => 'REJECTED',
      ComplaintStatus.cancelled => 'CANCELLED',
      ComplaintStatus.reopened => 'REOPENED',
      ComplaintStatus.onHold => 'ON HOLD',
    };
  }

  Color get color {
    return switch (this) {
      ComplaintStatus.pending => AppColors.statusPending,
      ComplaintStatus.accepted => AppColors.statusAccepted,
      ComplaintStatus.assigned => AppColors.statusAssigned,
      ComplaintStatus.inProgress => AppColors.statusInProgress,
      ComplaintStatus.resolved => AppColors.statusResolved,
      ComplaintStatus.verified => AppColors.statusVerified,
      ComplaintStatus.closed => AppColors.statusClosed,
      ComplaintStatus.rejected => AppColors.statusNegative,
      ComplaintStatus.cancelled => AppColors.statusNegative,
      ComplaintStatus.reopened => AppColors.statusReopened,
      ComplaintStatus.onHold => AppColors.statusOnHold,
    };
  }

  IconData get icon {
    return switch (this) {
      ComplaintStatus.pending => Icons.schedule,
      ComplaintStatus.accepted => Icons.check_circle_outline,
      ComplaintStatus.assigned => Icons.person_add_outlined,
      ComplaintStatus.inProgress => Icons.play_circle_outline,
      ComplaintStatus.resolved => Icons.check_circle,
      ComplaintStatus.verified => Icons.verified,
      ComplaintStatus.closed => Icons.archive,
      ComplaintStatus.rejected => Icons.cancel_outlined,
      ComplaintStatus.cancelled => Icons.close,
      ComplaintStatus.reopened => Icons.replay,
      ComplaintStatus.onHold => Icons.pause_circle_outline,
    };
  }

  bool get isTerminal {
    return this == ComplaintStatus.closed ||
        this == ComplaintStatus.cancelled ||
        this == ComplaintStatus.rejected;
  }

  bool get canBeCancelled {
    return this == ComplaintStatus.pending ||
        this == ComplaintStatus.accepted;
  }

  bool get canBeReopened {
    return this == ComplaintStatus.closed && this != ComplaintStatus.resolved;
  }
}

/// Parse ComplaintStatus from a string value
ComplaintStatus parseComplaintStatus(String value) {
  return ComplaintStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => ComplaintStatus.pending,
  );
}
