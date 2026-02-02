import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  // ── ColorScheme ───────────────────────────────────────────────────────────

  static const _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary — accent orange
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.accentContainer,
    onPrimaryContainer: AppColors.accentLight,

    // Secondary — lighter orange (tonal)
    secondary: AppColors.accentLight,
    onSecondary: AppColors.background,
    secondaryContainer: Color(0xFF2E1808),
    onSecondaryContainer: AppColors.accentLight,

    // Tertiary — success green
    tertiary: AppColors.success,
    onTertiary: AppColors.background,
    tertiaryContainer: Color(0xFF003D28),
    onTertiaryContainer: AppColors.success,

    // Error
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: Color(0xFF3D0014),
    onErrorContainer: AppColors.error,

    // Surface hierarchy
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: Color(0xFF090910),
    surfaceContainerLow: AppColors.background,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: Color(0xFF353545),
    onSurfaceVariant: AppColors.textSecondary,

    // Outline
    outline: Color(0xFF3A3A48),
    outlineVariant: AppColors.divider,

    // Misc
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: Color(0xFFB74000),
    surfaceTint: AppColors.accent,
  );

  // ── TextTheme — Exo 2 поверх dark defaults ────────────────────────

  static TextTheme get _textTheme =>
      GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  // ── AppBarTheme ───────────────────────────────────────────────────────────

  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textSecondary),
      );

  // ── NavigationBar (M3) ────────────────────────────────────────────────────

  static NavigationBarThemeData get _navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.accentContainer,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            );
          }
          return GoogleFonts.rubik(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  // ── CardTheme ─────────────────────────────────────────────────────────────

  static const _cardTheme = CardTheme(
    elevation: 0,
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: AppColors.divider),
    ),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  );

  // ── InputDecorationTheme ──────────────────────────────────────────────────

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.rubik(
          fontSize: 15,
          color: AppColors.textHint,
        ),
        labelStyle: GoogleFonts.rubik(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.rubik(
          fontSize: 13,
          color: AppColors.accent,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  // ── Buttons ───────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceContainer,
          disabledForegroundColor: AppColors.textHint,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.accent),
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.rubik(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // ── FAB ───────────────────────────────────────────────────────────────────

  static const _fabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.onAccent,
    elevation: 0,
    focusElevation: 0,
    hoverElevation: 0,
    shape: CircleBorder(),
  );

  // ── Chip ──────────────────────────────────────────────────────────────────

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: AppColors.accentContainer,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.rubik(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.rubik(
          fontSize: 13,
          color: AppColors.accent,
        ),
      );

  // ── TabBar ────────────────────────────────────────────────────────────────

  static TabBarTheme get _tabBarTheme => TabBarTheme(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: AppColors.divider,
      );

  // ── Misc ──────────────────────────────────────────────────────────────────

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: GoogleFonts.rubik(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        actionTextColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      );

  static DialogTheme get _dialogTheme => DialogTheme(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.rubik(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.rubik(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
      );

  static const _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColors.accent,
    linearTrackColor: AppColors.divider,
    circularTrackColor: AppColors.divider,
  );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentContainer;
          }
          return AppColors.surfaceContainer;
        }),
      );

  // ── ThemeData ─────────────────────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        navigationBarTheme: _navigationBarTheme,
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        floatingActionButtonTheme: _fabTheme,
        chipTheme: _chipTheme,
        tabBarTheme: _tabBarTheme,
        snackBarTheme: _snackBarTheme,
        dialogTheme: _dialogTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        switchTheme: _switchTheme,
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textPrimary,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surfaceContainer,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.rubik(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      );
}
