import 'package:flutter/material.dart';
import '../../features/todos/domain/enums/todo_priority.dart';
import '../theme/app_spacing.dart';

/// Priority badge adhering to WCAG Dual-Coding (Icon + Text + Background Color)
class PriorityBadge extends StatelessWidget {
  final TodoPriority priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    if (priority == TodoPriority.none) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag_rounded,
            size: 12,
            color: priority.color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: priority.color,
            ),
          ),
        ],
      ),
    );
  }
}
