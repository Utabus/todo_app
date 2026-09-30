import '../../domain/entities/subtask.dart';

class SubtaskDto {
  final String id;
  final String title;
  final bool isCompleted;
  final int? createdAtMillis;
  final int? updatedAtMillis;
  final int sortKey;

  const SubtaskDto({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.createdAtMillis,
    this.updatedAtMillis,
    this.sortKey = 0,
  });

  factory SubtaskDto.fromJson(Map<String, dynamic> json, String id) {
    return SubtaskDto(
      id: id,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAtMillis: json['createdAt'] is int ? json['createdAt'] as int : null,
      updatedAtMillis: json['updatedAt'] is int ? json['updatedAt'] as int : null,
      sortKey: json['sortKey'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAtMillis ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'sortKey': sortKey,
    };
  }

  Subtask toDomain() {
    return Subtask(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis!) : null,
      updatedAt: updatedAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(updatedAtMillis!) : null,
      sortKey: sortKey,
    );
  }

  factory SubtaskDto.fromDomain(Subtask domain) {
    return SubtaskDto(
      id: domain.id,
      title: domain.title,
      isCompleted: domain.isCompleted,
      createdAtMillis: domain.createdAt?.millisecondsSinceEpoch,
      updatedAtMillis: domain.updatedAt?.millisecondsSinceEpoch,
      sortKey: domain.sortKey,
    );
  }
}
