import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/task_row_item.dart';
import '../providers/todo_providers.dart';
import '../widgets/quick_add_modal.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  bool _isCompletedExpanded = true;

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayTodosProvider);
    final overdueAsync = ref.watch(overdueTodosProvider);
    final completedAsync = ref.watch(completedTodosProvider);
    final allTodosAsync = ref.watch(todoStreamProvider);
    final controller = ref.read(todoControllerProvider);

    final todayTasks = todayAsync.value ?? [];
    final overdueTasks = overdueAsync.value ?? [];
    final completedTasks = completedAsync.value ?? [];
    final allTasks = allTodosAsync.value ?? [];

    final totalCount = allTasks.length;
    final doneCount = completedTasks.length;
    final completionRate = totalCount == 0 ? 0.0 : doneCount / totalCount;
    final completionPercent = (completionRate * 100).toInt();

    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 20, color: AppColors.primaryContainer),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Synced status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.statusCompleted,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Synced',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 22),
                        color: AppColors.onSurfaceVariant,
                        onPressed: () => context.go(RouteNames.search),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Good morning, Alex',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Q4 Sprint 3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Daily Progress Summary Card (Bento Style)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.flag_rounded, size: 16, color: AppColors.primaryContainer),
                            SizedBox(width: 4),
                            Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$doneCount of $totalCount completed',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "You're on track to wrap up your planned deep work by 5:30 PM.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: completionRate,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Progress dial
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 5,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryContainer),
                        ),
                        Text(
                          '$completionPercent%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Overdue Section (if any)
            if (overdueTasks.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.error_outline_rounded, size: 16, color: AppColors.statusOverdue),
                      SizedBox(width: 5),
                      Text(
                        'ATTENTION REQUIRED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.statusOverdue,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Overdue (${overdueTasks.length})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final task in overdueTasks) ...[
                TaskRowItem(
                  todo: task,
                  onToggleComplete: (_) => controller.toggleComplete(task.id, !task.isCompleted),
                  onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
            ],

            // Today's Schedule Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${todayTasks.length} remaining',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (todayTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.done_all_rounded, size: 36, color: AppColors.statusCompleted),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'All caught up for today!',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enjoy your evening or add a new task below.',
                      style: TextStyle(fontSize: 12, color: AppColors.secondary),
                    ),
                  ],
                ),
              )
            else
              for (final task in todayTasks) ...[
                TaskRowItem(
                  todo: task,
                  onToggleComplete: (_) => controller.toggleComplete(task.id, !task.isCompleted),
                  onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

            const SizedBox(height: AppSpacing.lg),

            // Completed Section
            if (completedTasks.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isCompletedExpanded = !_isCompletedExpanded),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isCompletedExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_right_rounded,
                                  size: 20,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Completed (${completedTasks.length})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => controller.clearCompleted(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Clear all',
                                style: TextStyle(fontSize: 12, color: AppColors.secondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isCompletedExpanded) ...[
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          children: [
                            for (final task in completedTasks) ...[
                              TaskRowItem(
                                todo: task,
                                onToggleComplete: (_) => controller.toggleComplete(task.id, !task.isCompleted),
                                onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuickAddModal.show(context),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
