import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../features/todos/domain/entities/todo.dart';
import '../../features/todos/domain/enums/todo_priority.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'priority_badge.dart';

class TaskRowItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onTap;
  final bool isSelected;

  const TaskRowItem({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtasksCount = todo.actualSubtaskCount;
    final completedSubtasks = todo.actualCompletedSubtaskCount;

    String? dueText;
    if (todo.dueAt != null) {
      dueText = DateFormat('h:mm a').format(todo.dueAt!);
    }

    return Material(
      color: isSelected
          ? AppColors.primaryContainer.withValues(alpha: 0.08)
          : AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryContainer
                  : (todo.isOverdue ? AppColors.priorityHigh.withValues(alpha: 0.4) : AppColors.borderSubtle),
              width: isSelected || todo.isOverdue ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 48x48dp Accessible Hit-Target Checkbox
              SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Semantics(
                    label: 'Mark task as complete: ${todo.title}',
                    checked: todo.isCompleted,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleComplete(!todo.isCompleted);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: todo.isCompleted
                              ? AppColors.statusCompleted
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: todo.isCompleted
                                ? AppColors.statusCompleted
                                : (todo.isOverdue
                                    ? AppColors.priorityHigh
                                    : AppColors.outlineVariant),
                            width: 1.8,
                          ),
                        ),
                        child: todo.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 15,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              todo.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: todo.isCompleted
                                        ? AppColors.secondary
                                        : AppColors.onSurface,
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (todo.priority != TodoPriority.none) ...[
                            const SizedBox(width: AppSpacing.sm),
                            PriorityBadge(priority: todo.priority),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Metadata Row
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (dueText != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: todo.isOverdue
                                      ? AppColors.statusOverdue
                                      : AppColors.primaryContainer,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  dueText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: todo.isOverdue
                                            ? AppColors.statusOverdue
                                            : AppColors.onSurfaceVariant,
                                        fontWeight: todo.isOverdue
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          if (todo.categoryName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixed,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                todo.categoryName!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSecondaryFixed,
                                ),
                              ),
                            ),
                          if (subtasksCount > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.checklist_rounded,
                                  size: 13,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$completedSubtasks/$subtasksCount',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          for (final tag in todo.tags)
                            Text(
                              '#$tag',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
