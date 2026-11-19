import 'package:flutter/painting.dart';

/// Pioneers brand palette (derived from the company logo) and the semantic
/// colors used across the light theme.
class AppColors {
  AppColors._();

  // Brand
  static const Color navy = Color(0xFF173B5E);
  static const Color primary = Color(0xFF2476B9);
  static const Color secondary = Color(0xFF4B9BD3);
  static const Color cyan = Color(0xFF55C5E8);
  static const Color teal = Color(0xFF20B6B2);
  static const Color primaryContainer = Color(0xFFDCEBF8);
  static const Color accent = teal;

  // Surfaces
  static const Color background = Color(0xFFF5F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5EAF1);

  // Text
  static const Color ink = Color(0xFF1E293B);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF586579);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic. Foreground colours are tuned to reach >= 4.5:1 contrast on
  // their own *Bg colour (and on white), so text/icons in banners, chips and
  // stat cards stay readable.
  static const Color success = Color(0xFF0B6F69);
  static const Color successBg = Color(0xFFE2F5F3);
  static const Color warning = Color(0xFF875A0E);
  static const Color warningBg = Color(0xFFFDF1DC);
  static const Color danger = Color(0xFFB02F22);
  static const Color dangerBg = Color(0xFFFCE9E6);
  static const Color info = Color(0xFF1B5E96);
  static const Color infoBg = Color(0xFFE6F1FA);
  static const Color neutral = Color(0xFF525F73);
  static const Color neutralBg = Color(0xFFEDF1F6);
}
