import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/task_row_item.dart';
import '../../../todos/presentation/providers/todo_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(todoFilterProvider);
    final filterNotifier = ref.read(todoFilterProvider.notifier);
    final filteredAsync = ref.watch(filteredTodosProvider);
    final controller = ref.read(todoControllerProvider);

    final query = filterState.searchQuery;
    final results = query.isEmpty ? [] : (filteredAsync.value ?? []);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surfaceCanvas,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
            onChanged: (val) => filterNotifier.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search tasks, tags, notes...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.outline),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.secondary),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.secondary),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.setSearchQuery('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: query.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_rounded, size: 32, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Search Your Tasks',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Type keyword, tag (e.g. #flutter), or category name to quickly find tasks.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.secondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: ['#flutter', '#firebase', 'Sprint', 'Groceries'].map((chip) {
                        return ActionChip(
                          label: Text(chip),
                          backgroundColor: AppColors.surfaceCard,
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.secondary),
                          onPressed: () {
                            _searchController.text = chip;
                            filterNotifier.setSearchQuery(chip);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            )
          : results.isEmpty
              ? const EmptyStateView(
                  title: 'No matching tasks',
                  description: 'We couldn’t find any tasks matching your search query. Try another keyword.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final task = results[index];
                    return TaskRowItem(
                      todo: task,
                      onToggleComplete: (_) => controller.toggleComplete(task.id, !task.isCompleted),
                      onTap: () => context.push(RouteNames.taskDetailPath(task.id)),
                    );
                  },
                ),
    );
  }
}
