import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/category_providers.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Categories & Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text(
            'CATEGORIES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderSubtle),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cat.icon, size: 20, color: cat.color),
                  ),
                  title: Text(cat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCanvas,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      '${cat.taskCount} tasks',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'POPULAR TAGS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 0.8),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildTagChip('flutter', 6),
              _buildTagChip('architecture', 3),
              _buildTagChip('firebase', 2),
              _buildTagChip('security', 2),
              _buildTagChip('sprint', 4),
              _buildTagChip('meeting', 3),
              _buildTagChip('routine', 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String name, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$name',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
