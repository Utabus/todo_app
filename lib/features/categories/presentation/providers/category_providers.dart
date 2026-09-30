import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';

final categoriesProvider = Provider<List<CategoryEntity>>((ref) {
  return const [
    CategoryEntity(id: '1', name: 'Work', icon: Icons.work_outline_rounded, color: Color(0xFF2563EB), taskCount: 4),
    CategoryEntity(id: '2', name: 'Personal', icon: Icons.person_outline_rounded, color: Color(0xFF10B981), taskCount: 2),
    CategoryEntity(id: '3', name: 'Development', icon: Icons.code_rounded, color: Color(0xFF8B5CF6), taskCount: 3),
    CategoryEntity(id: '4', name: 'Learning', icon: Icons.school_outlined, color: Color(0xFFF59E0B), taskCount: 1),
  ];
});
