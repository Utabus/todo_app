import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/todo.dart';
import '../../domain/enums/todo_priority.dart';
import '../providers/todo_providers.dart';

class TodoDetailPage extends ConsumerStatefulWidget {
  final String taskId;

  const TodoDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends ConsumerState<TodoDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final _newSubtaskController = TextEditingController();
  bool _isAddingSubtask = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }

  void _saveChanges(Todo currentTodo) {
    final updated = currentTodo.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      updatedAt: DateTime.now(),
    );
    ref.read(todoControllerProvider).updateTodo(updated);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(todoControllerProvider).deleteTodo(widget.taskId);
              Navigator.pop(ctx);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoAsync = ref.watch(todoDetailProvider(widget.taskId));
    final controller = ref.read(todoControllerProvider);

    return todoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Task Detail')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (todo) {
        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: const Center(child: Text('Task not found')),
          );
        }

        if (!_initialized) {
          _titleController.text = todo.title;
          _descController.text = todo.description ?? '';
          _initialized = true;
        }

        final subtasksCount = todo.actualSubtaskCount;
        final completedSubtasks = todo.actualCompletedSubtaskCount;
        final subtaskProgress = subtasksCount == 0 ? 0.0 : completedSubtasks / subtasksCount;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) _saveChanges(todo);
          },
          child: Scaffold(
            backgroundColor: AppColors.surfaceCanvas,
            appBar: AppBar(
              title: const Text(
                'Task Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete Task',
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Completion Status Header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                controller.toggleComplete(todo.id, !todo.isCompleted);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: todo.isCompleted ? AppColors.statusCompleted : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: todo.isCompleted ? AppColors.statusCompleted : AppColors.outlineVariant,
                                    width: 2,
                                  ),
                                ),
                                child: todo.isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextField(
                                controller: _titleController,
                                onChanged: (_) => _saveChanges(todo),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: todo.isCompleted ? AppColors.secondary : AppColors.onSurface,
                                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Task Title',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.borderSubtle),
                        // Description TextField
                        TextField(
                          controller: _descController,
                          onChanged: (_) => _saveChanges(todo),
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Add description, notes, or guidelines...',
                            hintStyle: TextStyle(color: AppColors.outline),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Metadata Cards Grid
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        // Priority Row
                        _buildMetaRow(
                          icon: Icons.flag_rounded,
                          label: 'Priority',
                          child: DropdownButton<TodoPriority>(
                            value: todo.priority,
                            underline: const SizedBox(),
                            isDense: true,
                            items: TodoPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Icon(Icons.flag_rounded, size: 14, color: p.color),
                                    const SizedBox(width: 6),
                                    Text(p.label,
                                        style: TextStyle(fontSize: 13, color: p.color, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newPriority) {
                              if (newPriority != null) {
                                controller.updateTodo(todo.copyWith(priority: newPriority));
                              }
                            },
                          ),
                        ),
                        const Divider(height: 20, color: AppColors.borderSubtle),
                        // Due Date Row
                        _buildMetaRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Due Date',
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: todo.dueAt ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                controller.updateTodo(todo.copyWith(dueAt: picked));
                              }
                            },
                            child: Text(
                              todo.dueAt != null ? DateFormat('MMM d, yyyy').format(todo.dueAt!) : 'Set Date',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 20, color: AppColors.borderSubtle),
                        // Category Row
                        _buildMetaRow(
                          icon: Icons.folder_outlined,
                          label: 'Category',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todo.categoryName ?? 'General',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Subtasks Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtasks ($completedSubtasks of $subtasksCount)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            if (subtasksCount > 0)
                              Text(
                                '${(subtaskProgress * 100).toInt()}%',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                              ),
                          ],
                        ),
                        if (subtasksCount > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: subtaskProgress,
                              minHeight: 4,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primaryContainer),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        // Subtask items
                        for (final sub in todo.subtasks) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Checkbox(
                                    value: sub.isCompleted,
                                    onChanged: (val) {
                                      controller.toggleSubtask(todo.id, sub.id, val ?? false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    sub.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: sub.isCompleted ? AppColors.secondary : AppColors.onSurface,
                                      decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.outline),
                                  onPressed: () => controller.deleteSubtask(todo.id, sub.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        // Add Subtask Box
                        if (_isAddingSubtask) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newSubtaskController,
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter subtask...',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      controller.addSubtask(
                                        todo.id,
                                        Subtask(
                                          id: 's_${DateTime.now().millisecondsSinceEpoch}',
                                          title: val.trim(),
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      _newSubtaskController.clear();
                                      setState(() => _isAddingSubtask = false);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.primaryContainer),
                                onPressed: () {
                                  if (_newSubtaskController.text.trim().isNotEmpty) {
                                    controller.addSubtask(
                                      todo.id,
                                      Subtask(
                                        id: 's_${DateTime.now().millisecondsSinceEpoch}',
                                        title: _newSubtaskController.text.trim(),
                                        createdAt: DateTime.now(),
                                      ),
                                    );
                                    _newSubtaskController.clear();
                                    setState(() => _isAddingSubtask = false);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppColors.secondary),
                                onPressed: () => setState(() => _isAddingSubtask = false),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextButton.icon(
                            onPressed: () => setState(() => _isAddingSubtask = true),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Subtask'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryContainer,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      label: const Text('Delete Task',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.errorContainer),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        child,
      ],
    );
  }
}
