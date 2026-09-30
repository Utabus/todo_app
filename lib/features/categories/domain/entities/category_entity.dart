import 'package:flutter/material.dart';

class CategoryEntity {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int taskCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.taskCount = 0,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? taskCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      taskCount: taskCount ?? this.taskCount,
    );
  }
}
