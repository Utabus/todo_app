import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Task Overdue: Review Firebase security rules',
        'time': 'Yesterday, 3:00 PM',
        'isOverdue': true,
        'icon': Icons.warning_amber_rounded,
      },
      {
        'title': 'Upcoming: Team standup and sprint planning in 30 mins',
        'time': 'Today, 9:30 AM',
        'isOverdue': false,
        'icon': Icons.alarm_rounded,
      },
      {
        'title': 'Daily Focus Completed: 4 tasks checked off',
        'time': 'Yesterday, 6:00 PM',
        'isOverdue': false,
        'icon': Icons.check_circle_outline_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceCanvas,
      appBar: AppBar(
        title: const Text('Notifications & Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = notifications[index];
          final isOverdue = item['isOverdue'] as bool;

          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: isOverdue ? AppColors.priorityHigh.withValues(alpha: 0.3) : AppColors.borderSubtle,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isOverdue ? AppColors.errorContainer : AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: isOverdue ? AppColors.error : AppColors.primaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['time'] as String,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
