import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';

/// JD Logistics — Hybrid Premium Ocean Theme
///
/// Light:
/// Clean white logistics UI with soft blue clay edges.
///
/// Dark:
/// Ocean-neumorphic enterprise logistics dashboard.
/// No black, no blur, no glassmorphism, no purple.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg1,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.saffron,
          tertiary: AppColors.skyAccent,
          surface: AppColors.lightCard,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textDark,
          surfaceContainerHighest: AppColors.lightBg3,
        ),
        textTheme: _textTheme(AppColors.textDark),
        appBarTheme: _appBarTheme(AppColors.lightBg1, AppColors.textDark),
        cardTheme: _cardTheme(AppColors.lightCard, light: true),
        inputDecorationTheme: _inputTheme(dark: false),
        elevatedButtonTheme: _elevatedButtonTheme(),
        iconTheme: const IconThemeData(color: AppColors.primary),
        dividerTheme: const DividerThemeData(
          color: AppColors.skyBorder,
          thickness: 1,
        ),
        bottomNavigationBarTheme:
            _bottomNavTheme(AppColors.lightBg1, dark: false),
        switchTheme: _switchTheme(),
        chipTheme: _chipTheme(dark: false),
        extensions: const [AppThemeExtension.light],
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg1,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.oceanBlue,
          secondary: AppColors.portOrange,
          tertiary: AppColors.oceanCyan,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textWhite,
          surfaceContainerHighest: AppColors.darkElevated,
        ),
        textTheme: _textTheme(AppColors.textWhite),
        appBarTheme: _appBarTheme(AppColors.darkBg1, AppColors.textWhite),
        cardTheme: _cardTheme(AppColors.darkCard, light: false),
        inputDecorationTheme: _inputTheme(dark: true),
        elevatedButtonTheme: _elevatedButtonTheme(),
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
        ),
        bottomNavigationBarTheme:
            _bottomNavTheme(AppColors.darkBg1, dark: true),
        switchTheme: _switchTheme(),
        chipTheme: _chipTheme(dark: true),
        extensions: const [AppThemeExtension.dark],
      );

  static TextTheme _textTheme(Color base) => GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w900,
            color: base,
            letterSpacing: -0.9,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: base,
            letterSpacing: -0.7,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: base,
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: base,
            letterSpacing: -0.4,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: base,
            letterSpacing: -0.3,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: base,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: base,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: base,
            letterSpacing: 0.1,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: base,
            letterSpacing: 0.1,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: base,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: base,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: base.withValues(alpha: 0.72),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: base,
            letterSpacing: 0.3,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: base,
            letterSpacing: 0.3,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: base.withValues(alpha: 0.72),
            letterSpacing: 0.3,
          ),
        ),
      );

  static AppBarTheme _appBarTheme(Color bg, Color fg) => AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: fg),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: -0.3,
        ),
      );

  static CardThemeData _cardTheme(Color surface, {required bool light}) =>
      CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: light
            ? AppColors.clayShadowLight.withValues(alpha: 0.45)
            : AppColors.clayShadowDark.withValues(alpha: 0.90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: light ? AppColors.skyBorder : AppColors.darkBorder,
            width: 1.1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      );

  static InputDecorationTheme _inputTheme({required bool dark}) {
    final fillColor = dark ? AppColors.darkCard : AppColors.lightBg3;
    final borderColor = dark ? AppColors.darkBorder : AppColors.skyBorder;
    final focusBorder = dark ? AppColors.oceanBlue : AppColors.primary;
    final hintColor = dark ? AppColors.darkMuted : AppColors.textDarkHint;
    final labelColor = dark ? AppColors.darkSubtext : AppColors.textDark;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: focusBorder, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        color: hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelStyle: GoogleFonts.inter(
        color: labelColor,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      prefixIconColor: dark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
      suffixIconColor: dark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          shadowColor: AppColors.blueGlow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
      );

  static BottomNavigationBarThemeData _bottomNavTheme(
    Color bg, {
    required bool dark,
  }) =>
      BottomNavigationBarThemeData(
        backgroundColor: bg,
        selectedItemColor: dark ? AppColors.oceanBlue : AppColors.primary,
        unselectedItemColor:
            dark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );

  static SwitchThemeData _switchTheme() => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white.withValues(alpha: 0.86);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textDarkHint;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      );

  static ChipThemeData _chipTheme({required bool dark}) => ChipThemeData(
        backgroundColor: dark ? AppColors.darkCard : AppColors.lightBg3,
        selectedColor: dark
            ? AppColors.oceanBlue.withValues(alpha: 0.18)
            : AppColors.primary.withValues(alpha: 0.13),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: dark ? AppColors.darkSubtext : AppColors.textDark,
        ),
        side: BorderSide(
          color: dark ? AppColors.darkBorder : AppColors.skyBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color cardColor;
  final Color borderColor;
  final Color surfaceColor;
  final List<Color> primaryGradient;
  final List<Color> accentGradient;
  final List<Color> backgroundGradient;
  final List<Color> heroGradient;

  Color get glassColor => cardColor;
  Color get glassBorderColor => borderColor;

  const AppThemeExtension({
    required this.cardColor,
    required this.borderColor,
    required this.surfaceColor,
    required this.primaryGradient,
    required this.accentGradient,
    required this.backgroundGradient,
    required this.heroGradient,
  });

  static const light = AppThemeExtension(
    cardColor: AppColors.lightCard,
    borderColor: AppColors.skyBorder,
    surfaceColor: AppColors.lightBg2,
    primaryGradient: AppColors.primaryGradient,
    accentGradient: AppColors.accentGradient,
    backgroundGradient: AppColors.lightGradient,
    heroGradient: AppColors.heroGradient,
  );

  static const dark = AppThemeExtension(
    cardColor: AppColors.darkCard,
    borderColor: AppColors.darkBorder,
    surfaceColor: AppColors.darkSurface,
    primaryGradient: AppColors.primaryGradient,
    accentGradient: AppColors.accentGradient,
    backgroundGradient: AppColors.darkGradient,
    heroGradient: AppColors.oceanGradient,
  );

  @override
  AppThemeExtension copyWith({
    Color? cardColor,
    Color? borderColor,
    Color? surfaceColor,
    List<Color>? primaryGradient,
    List<Color>? accentGradient,
    List<Color>? backgroundGradient,
    List<Color>? heroGradient,
  }) =>
      AppThemeExtension(
        cardColor: cardColor ?? this.cardColor,
        borderColor: borderColor ?? this.borderColor,
        surfaceColor: surfaceColor ?? this.surfaceColor,
        primaryGradient: primaryGradient ?? this.primaryGradient,
        accentGradient: accentGradient ?? this.accentGradient,
        backgroundGradient: backgroundGradient ?? this.backgroundGradient,
        heroGradient: heroGradient ?? this.heroGradient,
      );

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) return this;

    return AppThemeExtension(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      primaryGradient: primaryGradient,
      accentGradient: accentGradient,
      backgroundGradient: backgroundGradient,
      heroGradient: heroGradient,
    );
  }
}