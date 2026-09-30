import '../enums/todo_priority.dart';
import '../enums/todo_status.dart';
import 'subtask.dart';

class Todo {
  final String id;
  final String title;
  final String? description;
  final TodoStatus status;
  final TodoPriority priority;
  final String? categoryId;
  final String? categoryName;
  final List<String> tags;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int subtaskCount;
  final int completedSubtaskCount;
  final int sortKey;
  final int schemaVersion;
  final List<Subtask> subtasks;

  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.status = TodoStatus.active,
    this.priority = TodoPriority.none,
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.dueAt,
    this.reminderAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.subtaskCount = 0,
    this.completedSubtaskCount = 0,
    this.sortKey = 1000,
    this.schemaVersion = 1,
    this.subtasks = const [],
  });

  bool get isCompleted => status == TodoStatus.completed;

  bool get isOverdue {
    if (isCompleted || dueAt == null) return false;
    return dueAt!.isBefore(DateTime.now());
  }

  int get actualSubtaskCount => subtasks.isNotEmpty ? subtasks.length : subtaskCount;
  int get actualCompletedSubtaskCount =>
      subtasks.isNotEmpty ? subtasks.where((s) => s.isCompleted).length : completedSubtaskCount;

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    TodoStatus? status,
    TodoPriority? priority,
    String? categoryId,
    String? categoryName,
    List<String>? tags,
    DateTime? dueAt,
    DateTime? reminderAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? subtaskCount,
    int? completedSubtaskCount,
    int? sortKey,
    int? schemaVersion,
    List<Subtask>? subtasks,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      tags: tags ?? this.tags,
      dueAt: dueAt ?? this.dueAt,
      reminderAt: reminderAt ?? this.reminderAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtaskCount: subtaskCount ?? this.subtaskCount,
      completedSubtaskCount: completedSubtaskCount ?? this.completedSubtaskCount,
      sortKey: sortKey ?? this.sortKey,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
