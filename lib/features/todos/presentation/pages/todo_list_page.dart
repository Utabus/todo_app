import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/task_row_item.dart';
import '../../domain/enums/todo_status.dart';
import '../providers/todo_providers.dart';
import '../widgets/filter_modal.dart';
import '../widgets/quick_add_modal.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  int _selectedTabIndex = 0; // 0: All, 1: Pending, 2: Completed

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredTodosProvider);
    final allAsync = ref.watch(todoStreamProvider);
    final filterState = ref.watch(todoFilterProvider);
    final controller = ref.read(todoControllerProvider);

    final allTodos = allAsync.value ?? [];
    var tasks = filteredAsync.value ?? [];

    if (_selectedTabIndex == 1) {
      tasks = tasks.where((t) => t.status != TodoStatus.completed).toList();
    } else if (_selectedTabIndex == 2) {
      tasks = tasks.where((t) => t.status == TodoStatus.completed).toList();
    }

    final totalCount = allTodos.length;
    final pendingCount = allTodos.where((t) => t.status != TodoStatus.completed).length;
    final doneCount = allTodos.where((t) => t.status == TodoStatus.completed).length;

    final hasActiveFilter = filterState.selectedPriority != null || filterState.selectedCategory != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 22),
                tooltip: 'Filter Tasks',
                onPressed: () => FilterModal.show(context),
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All / Pending / Completed)
          Container(
            color: AppColors.surfaceCard,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              children: [
                _buildSegment('All ($totalCount)', 0),
                const SizedBox(width: AppSpacing.sm),
                _buildSegment('Pending ($pendingCount)', 1),
                const SizedBox(width: AppSpacing.sm),
                _buildSegment('Completed ($doneCount)', 2),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),

          // Task List
          Expanded(
            child: tasks.isEmpty
                ? const EmptyStateView(
                    title: 'No tasks found',
                    description: 'No tasks match your current filters. Try changing or clearing your filters.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskRowItem(
                        todo: task,
                        onToggleComplete: (_) => controller.toggleComplete(task.id, !task.isCompleted),
                        onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                      );
                    },
                  ),
          ),
        ],
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

  Widget _buildSegment(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryContainer : AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
