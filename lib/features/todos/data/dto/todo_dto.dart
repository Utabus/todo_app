import '../../domain/entities/todo.dart';
import '../../domain/enums/todo_priority.dart';
import '../../domain/enums/todo_status.dart';

class TodoDto {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? categoryId;
  final String? categoryName;
  final List<String> tags;
  final int? dueAtMillis;
  final int? reminderAtMillis;
  final int? completedAtMillis;
  final int? createdAtMillis;
  final int? updatedAtMillis;
  final int subtaskCount;
  final int completedSubtaskCount;
  final int sortKey;
  final int schemaVersion;

  const TodoDto({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.dueAtMillis,
    this.reminderAtMillis,
    this.completedAtMillis,
    this.createdAtMillis,
    this.updatedAtMillis,
    this.subtaskCount = 0,
    this.completedSubtaskCount = 0,
    this.sortKey = 1000,
    this.schemaVersion = 1,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json, String id) {
    return TodoDto(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      priority: json['priority'] as String? ?? 'none',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      dueAtMillis: json['dueAt'] is int ? json['dueAt'] as int : null,
      reminderAtMillis: json['reminderAt'] is int ? json['reminderAt'] as int : null,
      completedAtMillis: json['completedAt'] is int ? json['completedAt'] as int : null,
      createdAtMillis: json['createdAt'] is int ? json['createdAt'] as int : null,
      updatedAtMillis: json['updatedAt'] is int ? json['updatedAt'] as int : null,
      subtaskCount: json['subtaskCount'] as int? ?? 0,
      completedSubtaskCount: json['completedSubtaskCount'] as int? ?? 0,
      sortKey: json['sortKey'] as int? ?? 1000,
      schemaVersion: json['schemaVersion'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'tags': tags,
      'dueAt': dueAtMillis,
      'reminderAt': reminderAtMillis,
      'completedAt': completedAtMillis,
      'createdAt': createdAtMillis ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'subtaskCount': subtaskCount,
      'completedSubtaskCount': completedSubtaskCount,
      'sortKey': sortKey,
      'schemaVersion': schemaVersion,
    };
  }

  Todo toDomain() {
    return Todo(
      id: id,
      title: title,
      description: description,
      status: TodoStatus.fromString(status),
      priority: TodoPriority.fromString(priority),
      categoryId: categoryId,
      categoryName: categoryName,
      tags: tags,
      dueAt: dueAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(dueAtMillis!) : null,
      reminderAt: reminderAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(reminderAtMillis!) : null,
      completedAt: completedAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(completedAtMillis!) : null,
      createdAt: createdAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis!) : null,
      updatedAt: updatedAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(updatedAtMillis!) : null,
      subtaskCount: subtaskCount,
      completedSubtaskCount: completedSubtaskCount,
      sortKey: sortKey,
      schemaVersion: schemaVersion,
    );
  }

  factory TodoDto.fromDomain(Todo domain) {
    return TodoDto(
      id: domain.id,
      title: domain.title,
      description: domain.description,
      status: domain.status.wireName,
      priority: domain.priority.wireName,
      categoryId: domain.categoryId,
      categoryName: domain.categoryName,
      tags: domain.tags,
      dueAtMillis: domain.dueAt?.millisecondsSinceEpoch,
      reminderAtMillis: domain.reminderAt?.millisecondsSinceEpoch,
      completedAtMillis: domain.completedAt?.millisecondsSinceEpoch,
      createdAtMillis: domain.createdAt?.millisecondsSinceEpoch,
      updatedAtMillis: domain.updatedAt?.millisecondsSinceEpoch,
      subtaskCount: domain.subtaskCount,
      completedSubtaskCount: domain.completedSubtaskCount,
      sortKey: domain.sortKey,
      schemaVersion: domain.schemaVersion,
    );
  }
}
