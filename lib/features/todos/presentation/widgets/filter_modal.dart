import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/enums/todo_priority.dart';
import '../providers/todo_providers.dart';

class FilterModal extends ConsumerStatefulWidget {
  const FilterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterModal(),
    );
  }

  @override
  ConsumerState<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<FilterModal> {
  TodoPriority? _selectedPriority;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final filterState = ref.read(todoFilterProvider);
    _selectedPriority = filterState.selectedPriority;
    _selectedCategory = filterState.selectedCategory;
  }

  void _applyFilter() {
    final notifier = ref.read(todoFilterProvider.notifier);
    notifier.setPriority(_selectedPriority);
    notifier.setCategory(_selectedCategory);
    Navigator.pop(context);
  }

  void _resetFilter() {
    setState(() {
      _selectedPriority = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        child: Padding(
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilter,
                    child: const Text('Reset', style: TextStyle(color: AppColors.secondary)),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: AppSpacing.sm),
              // Priority Section
              const Text(
                'By Priority',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _buildPriorityChip(null, 'All Priorities'),
                  _buildPriorityChip(TodoPriority.high, 'High'),
                  _buildPriorityChip(TodoPriority.medium, 'Medium'),
                  _buildPriorityChip(TodoPriority.low, 'Low'),
                  _buildPriorityChip(TodoPriority.none, 'None'),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Category Section
              const Text(
                'By Category',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  _buildCategoryChip(null, 'All Categories'),
                  for (final cat in categories)
                    _buildCategoryChip(cat.name, cat.name),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TodoPriority? priority, String label) {
    final isSelected = _selectedPriority == priority;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondaryContainer,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppColors.primaryContainer : AppColors.secondary,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedPriority = priority);
      },
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondaryContainer,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? AppColors.primaryContainer : AppColors.secondary,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = category);
      },
    );
  }
}
