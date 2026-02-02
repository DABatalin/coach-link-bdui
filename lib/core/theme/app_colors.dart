import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Backgrounds (elevation hierarchy: darker = lower) ─────────────────────
  /// Scaffold background — самый тёмный слой
  static const background = Color(0xFF0D0D10);

  /// Карточки, ListTile, NavBar
  static const surface = Color(0xFF18181C);

  /// Приподнятые карточки, диалоги
  static const surfaceContainer = Color(0xFF222228);

  /// Максимальная высота — модалы, Snackbar
  static const surfaceContainerHigh = Color(0xFF2C2C35);

  // ── Accent — Orange (цвет беговой дорожки, огня, энергии) ─────────────────
  static const accent = Color(0xFFFF6B35);
  static const accentLight = Color(0xFFFF8C5A);

  /// Слабый оранжевый фон для чипов, индикатора навбара
  static const accentContainer = Color(0xFF3D1E0E);
  static const onAccent = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Основной текст — тёплый белый (не #FFF, чтобы не слепил)
  static const textPrimary = Color(0xFFEEEEF2);

  /// Вторичный — приглушённый серый
  static const textSecondary = Color(0xFF8A8A98);

  /// Подсказки, placeholder
  static const textHint = Color(0xFF4A4A58);

  // ── Status ────────────────────────────────────────────────────────────────
  static const error = Color(0xFFFF4D6A);
  static const onError = Color(0xFFFFFFFF);
  static const success = Color(0xFF00D68F);
  static const warning = Color(0xFFFFAA44);
  static const overdue = Color(0xFFFF4D6A);

  // ── Utility ───────────────────────────────────────────────────────────────
  static const divider = Color(0xFF242430);
}
