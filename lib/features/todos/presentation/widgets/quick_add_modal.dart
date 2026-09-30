import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/todo.dart';
import '../../domain/enums/todo_priority.dart';
import '../../domain/enums/todo_status.dart';
import '../providers/todo_providers.dart';

class QuickAddModal extends ConsumerStatefulWidget {
  const QuickAddModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddModal(),
    );
  }

  @override
  ConsumerState<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends ConsumerState<QuickAddModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  TodoPriority _selectedPriority = TodoPriority.none;
  String _selectedSchedule = 'Today';
  String _selectedCategory = 'Work';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    DateTime dueAt = DateTime.now();
    if (_selectedSchedule == 'Tomorrow') {
      dueAt = DateTime.now().add(const Duration(days: 1));
    } else if (_selectedSchedule == 'This Weekend') {
      dueAt = DateTime.now().add(const Duration(days: 3));
    }

    final newTask = Todo(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      status: TodoStatus.active,
      priority: _selectedPriority,
      dueAt: dueAt,
      categoryId: _selectedCategory.toLowerCase(),
      categoryName: _selectedCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(todoControllerProvider).createTodo(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle),
            left: BorderSide(color: AppColors.borderSubtle),
            right: BorderSide(color: AppColors.borderSubtle),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Sheet header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'NEW ENTRY',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.secondary,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.secondary,
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Title Input
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: AppColors.outline,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
                    ),
                    contentPadding: EdgeInsets.only(bottom: AppSpacing.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Description Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCanvas,
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_rounded, size: 18, color: AppColors.secondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _descController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            hintText: 'Add details, subtasks, or link references...',
                            hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Schedule Presets
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildScheduleChip('Today', Icons.today_rounded),
                      const SizedBox(width: AppSpacing.sm),
                      _buildScheduleChip('Tomorrow', Icons.calendar_today_rounded),
                      const SizedBox(width: AppSpacing.sm),
                      _buildScheduleChip('This Weekend', Icons.weekend_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Priority Selector
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _buildPriorityChip(TodoPriority.high),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPriorityChip(TodoPriority.medium),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPriorityChip(TodoPriority.low),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPriorityChip(TodoPriority.none),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Category Selector
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Work', 'Personal', 'Development', 'Learning'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.secondaryContainer,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.onSecondaryContainer : AppColors.secondary,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.onSurface)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                          ),
                        ),
                        child: const Text('Save Task',
                            style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleChip(String title, IconData icon) {
    final isSelected = _selectedSchedule == title;
    return InkWell(
      onTap: () => setState(() => _selectedSchedule = title),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryContainer : AppColors.surfaceCanvas,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.4) : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primaryContainer : AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primaryContainer : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TodoPriority priority) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPriority = priority),
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? priority.backgroundColor : AppColors.surfaceCanvas,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              color: isSelected ? priority.color : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              priority.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? priority.color : AppColors.secondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
