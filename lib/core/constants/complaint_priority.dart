import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum ComplaintPriority {
  low,
  medium,
  high,
  urgent,
}

extension ComplaintPriorityExtension on ComplaintPriority {
  String get label {
    return switch (this) {
      ComplaintPriority.low => 'LOW',
      ComplaintPriority.medium => 'MEDIUM',
      ComplaintPriority.high => 'HIGH',
      ComplaintPriority.urgent => 'URGENT',
    };
  }

  Color get color {
    return switch (this) {
      ComplaintPriority.low => AppColors.priorityLow,
      ComplaintPriority.medium => AppColors.priorityMedium,
      ComplaintPriority.high => AppColors.priorityHigh,
      ComplaintPriority.urgent => AppColors.priorityUrgent,
    };
  }

  IconData get icon {
    return switch (this) {
      ComplaintPriority.low => Icons.arrow_downward,
      ComplaintPriority.medium => Icons.remove,
      ComplaintPriority.high => Icons.arrow_upward,
      ComplaintPriority.urgent => Icons.priority_high,
    };
  }

  int get sortOrder {
    return switch (this) {
      ComplaintPriority.urgent => 0,
      ComplaintPriority.high => 1,
      ComplaintPriority.medium => 2,
      ComplaintPriority.low => 3,
    };
  }

  static ComplaintPriority fromString(String value) {
    return ComplaintPriority.values.firstWhere(
      (priority) => priority.name == value,
      orElse: () => ComplaintPriority.medium,
    );
  }

  static ComplaintPriority fromIndex(int index) {
    if (index >= 0 && index < ComplaintPriority.values.length) {
      return ComplaintPriority.values[index];
    }
    return ComplaintPriority.medium;
  }
}
