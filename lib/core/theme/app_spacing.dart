import 'package:flutter/material.dart';

/// Spacing and Shape tokens adhering to the Stitch Design System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
}

class AppRadius {
  static const double sm = 4.0;
  static const double small = 8.0;    // Standard cards, inputs, buttons
  static const double medium = 12.0;  // Subtask containers, chips
  static const double large = 16.0;   // Modal bottom sheets, primary cards
  static const double xl = 20.0;      // Dialogs, top sheet handles
  static const double pill = 999.0;   // Badges, tags, filter chips

  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
