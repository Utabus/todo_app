import 'package:flutter/material.dart';

/// Semantic Color Tokens based on Stitch 'Calm Productivity' Design System
class AppColors {
  // Primary & Surface
  static const primary = Color(0xFF004AC6);
  static const primaryContainer = Color(0xFF2563EB);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFEEEFFF);
  static const primaryFixed = Color(0xFFDBE1FF);
  static const primaryFixedDim = Color(0xFFB4C5FF);
  static const onPrimaryFixed = Color(0xFF00174B);

  // Surface & Canvas
  static const surfaceCanvas = Color(0xFFF8FAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFCBDBF5);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const surfaceContainerHighest = Color(0xFFD3E4FE);

  // Text & Content
  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF434655);
  static const onBackground = Color(0xFF0B1C30);
  static const background = Color(0xFFF8F9FF);

  // Secondary & Slate
  static const secondary = Color(0xFF515F74);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD5E3FC);
  static const onSecondaryContainer = Color(0xFF57657A);
  static const secondaryFixed = Color(0xFFD5E3FC);
  static const onSecondaryFixed = Color(0xFF0D1C2E);

  // Borders & Outlines
  static const borderSubtle = Color(0xFFE2E8F0);
  static const outline = Color(0xFF737686);
  static const outlineVariant = Color(0xFFC3C6D7);

  // Semantic Priorities (Dual-Coding with WCAG AAA contrast)
  static const priorityHigh = Color(0xFFEF4444);
  static const priorityHighBg = Color(0xFFFEE2E2);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityMediumBg = Color(0xFFFEF3C7);
  static const priorityLow = Color(0xFF3B82F6);
  static const priorityLowBg = Color(0xFFEFF6FF);
  static const priorityNone = Color(0xFF94A3B8);
  static const priorityNoneBg = Color(0xFFF1F5F9);

  // Semantic Status
  static const statusActive = Color(0xFF2563EB);
  static const statusCompleted = Color(0xFF10B981);
  static const statusOverdue = Color(0xFFEF4444);
  static const statusArchived = Color(0xFF64748B);

  // Error & Warning
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}
