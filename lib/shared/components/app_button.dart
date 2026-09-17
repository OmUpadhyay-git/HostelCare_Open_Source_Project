import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outlined, text, destructive }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : type = AppButtonType.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : type = AppButtonType.secondary;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : type = AppButtonType.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : type = AppButtonType.text;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : type = AppButtonType.destructive;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final button = switch (type) {
      AppButtonType.primary => _buildElevatedButton(colorScheme),
      AppButtonType.secondary => _buildSecondaryButton(colorScheme),
      AppButtonType.outlined => _buildOutlinedButton(colorScheme),
      AppButtonType.text => _buildTextButton(colorScheme),
      AppButtonType.destructive => _buildDestructiveButton(colorScheme),
    };

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildElevatedButton(ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(isFullWidth ? double.infinity : 0, _getButtonHeight()),
        padding: _getButtonPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildChild(colorScheme.onPrimary),
    );
  }

  Widget _buildSecondaryButton(ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.onSurface,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(isFullWidth ? double.infinity : 0, _getButtonHeight()),
        padding: _getButtonPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildChild(colorScheme.onSurface),
    );
  }

  Widget _buildOutlinedButton(ColorScheme colorScheme) {
    return OutlinedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(isFullWidth ? double.infinity : 0, _getButtonHeight()),
        padding: _getButtonPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: _isEnabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: _buildChild(colorScheme.primary),
    );
  }

  Widget _buildTextButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(isFullWidth ? double.infinity : 0, _getButtonHeight()),
        padding: _getButtonPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildChild(colorScheme.primary),
    );
  }

  Widget _buildDestructiveButton(ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: Size(isFullWidth ? double.infinity : 0, _getButtonHeight()),
        padding: _getButtonPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _buildChild(AppColors.onPrimary),
    );
  }

  Widget _buildChild(Color defaultColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: defaultColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(label, style: _getLabelStyle()),
        ],
      );
    }

    return Text(label, style: _getLabelStyle());
  }

  double _getButtonHeight() {
    return switch (size) {
      AppButtonSize.small => 36,
      AppButtonSize.medium => 48,
      AppButtonSize.large => 56,
    };
  }

  EdgeInsets _getButtonPadding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 12),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24),
    };
  }

  double _getIconSize() {
    return switch (size) {
      AppButtonSize.small => 16,
      AppButtonSize.medium => 20,
      AppButtonSize.large => 24,
    };
  }

  TextStyle _getLabelStyle() {
    return switch (size) {
      AppButtonSize.small => AppTextStyles.labelLarge,
      AppButtonSize.medium => AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      AppButtonSize.large => AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
    };
  }
}
