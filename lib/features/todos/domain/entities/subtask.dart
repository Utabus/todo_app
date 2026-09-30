class Subtask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int sortKey;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
    this.sortKey = 0,
  });

  Subtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortKey,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortKey: sortKey ?? this.sortKey,
    );
  }
}
