import 'package:flutter/material.dart';

class AppColors {
  // Brand & Primary
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color accent = Color(0xFFF59E0B); // Amber

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Very light slate
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // States & Indicators
  static const Color expense = Color(0xFFEF4444); // Red
  static const Color income = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Category Colors
  static const Color food = Color(0xFFFF6B6B);
  static const Color transport = Color(0xFF4ECDC4);
  static const Color bills = Color(0xFF45B7D1);
  static const Color entertainment = Color(0xFF96CEB4);
  static const Color shopping = Color(0xFFFFBE76);
  static const Color health = Color(0xFFFF7979);
  static const Color education = Color(0xFFA29BFE);
  static const Color other = Color(0xFFB2BEC3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient summaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
