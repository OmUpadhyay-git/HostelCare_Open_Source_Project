import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppStatus {
  active,
  inactive,
  disabled,
}

extension AppStatusExtension on AppStatus {
  String get label {
    return switch (this) {
      AppStatus.active => 'ACTIVE',
      AppStatus.inactive => 'INACTIVE',
      AppStatus.disabled => 'DISABLED',
    };
  }

  Color get color {
    return switch (this) {
      AppStatus.active => AppColors.success,
      AppStatus.inactive => AppColors.onSurfaceMutedLight,
      AppStatus.disabled => AppColors.error,
    };
  }

  IconData get icon {
    return switch (this) {
      AppStatus.active => Icons.check_circle,
      AppStatus.inactive => Icons.cancel,
      AppStatus.disabled => Icons.block,
    };
  }
}
