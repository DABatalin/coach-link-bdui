import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF5E92F3);
  static const primaryDark = Color(0xFF003C8F);
  static const onPrimary = Colors.white;

  // Secondary
  static const secondary = Color(0xFF43A047);
  static const secondaryLight = Color(0xFF76D275);
  static const secondaryDark = Color(0xFF00701A);
  static const onSecondary = Colors.white;

  // Background
  static const background = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const surfaceVariant = Color(0xFFE8E8E8);

  // Text
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  // Status
  static const error = Color(0xFFD32F2F);
  static const success = Color(0xFF388E3C);
  static const warning = Color(0xFFF57C00);
  static const overdue = Color(0xFFE53935);

  // Divider
  static const divider = Color(0xFFE0E0E0);
}
