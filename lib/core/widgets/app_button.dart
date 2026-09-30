import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum ButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: type == ButtonType.primary ? AppColors.onPrimary : AppColors.primaryContainer,
        ),
      );
    } else {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      );
    }

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: effectiveWidth,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: childContent,
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: effectiveWidth,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: childContent,
          ),
        );
      case ButtonType.outlined:
        return SizedBox(
          width: effectiveWidth,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: const BorderSide(color: AppColors.borderSubtle),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            ),
            child: childContent,
          ),
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          child: childContent,
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.onPrimary;
      case ButtonType.secondary:
        return AppColors.onSecondaryContainer;
      case ButtonType.outlined:
        return AppColors.onSurface;
      case ButtonType.text:
        return AppColors.primaryContainer;
    }
  }
}
