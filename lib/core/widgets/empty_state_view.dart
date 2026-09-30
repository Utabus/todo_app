import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

enum EmptyStateType { empty, error, offline, completed }

class EmptyStateView extends StatelessWidget {
  final EmptyStateType type;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    this.type = EmptyStateType.empty,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (type) {
      case EmptyStateType.empty:
        icon = Icons.inbox_outlined;
        iconColor = AppColors.primaryContainer;
        iconBg = AppColors.primaryFixedDim.withValues(alpha: 0.3);
        break;
      case EmptyStateType.completed:
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.statusCompleted;
        iconBg = AppColors.statusCompleted.withValues(alpha: 0.12);
        break;
      case EmptyStateType.offline:
        icon = Icons.wifi_off_rounded;
        iconColor = AppColors.secondary;
        iconBg = AppColors.secondaryContainer.withValues(alpha: 0.5);
        break;
      case EmptyStateType.error:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        iconBg = AppColors.errorContainer;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 160,
                height: 42,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
