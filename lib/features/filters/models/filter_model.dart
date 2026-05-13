// ============================================================
//  features/filters/models/filter_model.dart
// ============================================================
import 'package:flutter/material.dart';

enum FilterType {
  // Color
  none, vivid, noir, vintage, cool, warm, fade, neon, rose, teal,
  // Artistic
  sketch, glitch, vignette,
  // Face AR
  beautySmooth, dogEars, sunglasses, rainbow, heartEyes,
  // Innovative / Mood
  dreamy, infrared, oilPaint, pixelSort,
}

enum FilterCategory { color, artistic, faceAR, mood }

class FilterModel {
  final FilterType     type;
  final String         name;
  final FilterCategory category;
  final List<double>?  colorMatrix; // 4×5 matrix; null = painter-only
  final String         emoji;
  final List<Color>    gradientColors;

  const FilterModel({
    required this.type,
    required this.name,
    required this.category,
    required this.emoji,
    required this.gradientColors,
    this.colorMatrix,
  });
}
