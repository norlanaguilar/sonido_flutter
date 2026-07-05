import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.accent,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        labelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        dividerColor: AppColors.border,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.waveformInactive,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accentGlow,
        trackHeight: 2.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary),
        displayMedium: TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary),
        displaySmall: TextStyle(fontFamily: 'PlayfairDisplay', color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
        bodySmall: TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.textMuted, fontSize: 11),
        labelLarge: TextStyle(fontFamily: 'Outfit', color: AppColors.accent, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.textMuted, fontSize: 11),
        labelSmall: TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.textMuted, fontSize: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Outfit',
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
      ),
    );
  }
}
