import 'package:flutter/material.dart';

enum TodoPriority {
  high('High', 'high', Color(0xFFEF4444), Color(0xFFFEE2E2)),
  medium('Medium', 'medium', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  low('Low', 'low', Color(0xFF3B82F6), Color(0xFFEFF6FF)),
  none('None', 'none', Color(0xFF94A3B8), Color(0xFFF1F5F9));

  final String label;
  final String wireName;
  final Color color;
  final Color backgroundColor;

  const TodoPriority(this.label, this.wireName, this.color, this.backgroundColor);

  static TodoPriority fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'high' => TodoPriority.high,
      'medium' => TodoPriority.medium,
      'low' => TodoPriority.low,
      _ => TodoPriority.none,
    };
  }
}
