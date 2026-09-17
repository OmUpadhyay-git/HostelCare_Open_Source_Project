import 'package:flutter/material.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
    ),
  );
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
      actions: [
        AppButton.text(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (isDestructive)
          AppButton.destructive(
            label: confirmLabel,
            isFullWidth: false,
            onPressed: () => Navigator.of(context).pop(true),
          )
        else
          AppButton(
            label: confirmLabel,
            isFullWidth: false,
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    );
  }
}
