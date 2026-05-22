import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark
        ? const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: AppColors.darkPrimaryContainer,
            onPrimaryContainer: AppColors.primaryLight,
            secondary: AppColors.darkTextSecondary,
            onSecondary: AppColors.darkTextPrimary,
            surface: AppColors.darkSurface,
            onSurface: AppColors.darkTextPrimary,
            error: AppColors.danger,
            onError: Colors.white,
            outline: AppColors.darkBorder,
            surfaceContainerHighest: AppColors.darkSurfaceSoft,
          )
        : const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: AppColors.lightPrimaryContainer,
            onPrimaryContainer: AppColors.primaryDark,
            secondary: AppColors.lightTextSecondary,
            onSecondary: AppColors.lightTextPrimary,
            surface: AppColors.lightSurface,
            onSurface: AppColors.lightTextPrimary,
            error: AppColors.danger,
            onError: Colors.white,
            outline: AppColors.lightBorder,
            surfaceContainerHighest: AppColors.lightSurfaceSoft,
          );

    final textTheme = _textTheme(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      primaryColor: AppColors.primary,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.shadow.withValues(alpha: isDark ? 0.0 : 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.outline.withValues(alpha: 0.72)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceSoft : AppColors.surfaceHighlight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        helperStyle: textTheme.bodySmall,
        border: _inputBorder(colors.outline),
        enabledBorder: _inputBorder(colors.outline.withValues(alpha: 0.9)),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.3),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.onSurface,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          side: BorderSide(color: colors.outline.withValues(alpha: 0.85)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline.withValues(alpha: 0.65),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        iconColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        textColor: colors.onSurface,
        subtitleTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: AppColors.primary,
        disabledColor: colors.surfaceContainerHighest,
        side: BorderSide(color: colors.outline.withValues(alpha: 0.85)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelMedium!,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: isDark ? 0.18 : 0.55),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceSoft : AppColors.lightTextPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextTheme _textTheme(bool isDark) {
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.15,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.15,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData scaleTheme(ThemeData base, double scale) {
    if (scale == 1) {
      return base;
    }

    final inputTheme = base.inputDecorationTheme;

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          fontSize: (base.appBarTheme.titleTextStyle?.fontSize ?? 18) * scale,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          side: (base.cardTheme.shape as RoundedRectangleBorder?)?.side ?? BorderSide.none,
        ),
      ),
      inputDecorationTheme: inputTheme.copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 16 * scale,
        ),
        hintStyle: inputTheme.hintStyle?.copyWith(
          fontSize: (inputTheme.hintStyle?.fontSize ?? 14) * scale,
        ),
        labelStyle: inputTheme.labelStyle?.copyWith(
          fontSize: (inputTheme.labelStyle?.fontSize ?? 12) * scale,
        ),
        border: _scaledBorder(inputTheme.border, scale),
        enabledBorder: _scaledBorder(inputTheme.enabledBorder, scale),
        focusedBorder: _scaledBorder(inputTheme.focusedBorder, scale),
        errorBorder: _scaledBorder(inputTheme.errorBorder, scale),
        focusedErrorBorder: _scaledBorder(inputTheme.focusedErrorBorder, scale),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: base.elevatedButtonTheme.style?.copyWith(
          minimumSize: WidgetStatePropertyAll(Size(double.infinity, 52 * scale)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: base.outlinedButtonTheme.style?.copyWith(
          minimumSize: WidgetStatePropertyAll(Size(double.infinity, 52 * scale)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(fontSizeFactor: scale),
    );
  }

  static InputBorder? _scaledBorder(InputBorder? border, double scale) {
    if (border is! OutlineInputBorder) {
      return border;
    }

    return border.copyWith(
      borderRadius: BorderRadius.circular(12 * scale),
      borderSide: border.borderSide.copyWith(width: border.borderSide.width * scale),
    );
  }
}
