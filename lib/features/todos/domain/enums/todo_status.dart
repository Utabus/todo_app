enum TodoStatus {
  active('active'),
  completed('completed'),
  archived('archived');

  final String wireName;
  const TodoStatus(this.wireName);

  static TodoStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'completed' => TodoStatus.completed,
      'archived' => TodoStatus.archived,
      _ => TodoStatus.active,
    };
  }
}
