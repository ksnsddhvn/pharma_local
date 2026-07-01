import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color otcColor;
  final Color rxColor;
  final Color scheduleHColor;
  final Color scheduleH1Color;
  final Color cosmeticsColor;
  final Color expiryGood;
  final Color expiryWarning;
  final Color expiryCritical;
  final LinearGradient gradientPrimary;
  final LinearGradient gradientCard;

  AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.otcColor,
    required this.rxColor,
    required this.scheduleHColor,
    required this.scheduleH1Color,
    required this.cosmeticsColor,
    required this.expiryGood,
    required this.expiryWarning,
    required this.expiryCritical,
    required this.gradientPrimary,
    required this.gradientCard,
  });

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? otcColor,
    Color? rxColor,
    Color? scheduleHColor,
    Color? scheduleH1Color,
    Color? cosmeticsColor,
    Color? expiryGood,
    Color? expiryWarning,
    Color? expiryCritical,
    LinearGradient? gradientPrimary,
    LinearGradient? gradientCard,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      otcColor: otcColor ?? this.otcColor,
      rxColor: rxColor ?? this.rxColor,
      scheduleHColor: scheduleHColor ?? this.scheduleHColor,
      scheduleH1Color: scheduleH1Color ?? this.scheduleH1Color,
      cosmeticsColor: cosmeticsColor ?? this.cosmeticsColor,
      expiryGood: expiryGood ?? this.expiryGood,
      expiryWarning: expiryWarning ?? this.expiryWarning,
      expiryCritical: expiryCritical ?? this.expiryCritical,
      gradientPrimary: gradientPrimary ?? this.gradientPrimary,
      gradientCard: gradientCard ?? this.gradientCard,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      otcColor: Color.lerp(otcColor, other.otcColor, t)!,
      rxColor: Color.lerp(rxColor, other.rxColor, t)!,
      scheduleHColor: Color.lerp(scheduleHColor, other.scheduleHColor, t)!,
      scheduleH1Color: Color.lerp(scheduleH1Color, other.scheduleH1Color, t)!,
      cosmeticsColor: Color.lerp(cosmeticsColor, other.cosmeticsColor, t)!,
      expiryGood: Color.lerp(expiryGood, other.expiryGood, t)!,
      expiryWarning: Color.lerp(expiryWarning, other.expiryWarning, t)!,
      expiryCritical: Color.lerp(expiryCritical, other.expiryCritical, t)!,
      gradientPrimary: LinearGradient.lerp(gradientPrimary, other.gradientPrimary, t)!,
      gradientCard: LinearGradient.lerp(gradientCard, other.gradientCard, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}

class AppTheme {
  static const _primary = Color(0xFF1E40AF); // Deep Corporate Blue
  static const _primaryDark = Color(0xFF1E3A8A);
  static const _primaryLight = Color(0xFF60A5FA);
  
  static const _success = Color(0xFF10B981); // Paid/Settled state
  static const _warning = Color(0xFFF59E0B);
  static const _error = Color(0xFFEF4444); // Credit Tabs/Low Stock
  static const _info = Color(0xFF3B82F6);

  static const _otcColor = Color(0xFF10B981);
  static const _rxColor = Color(0xFF3B82F6);
  static const _scheduleHColor = Color(0xFFF59E0B);
  static const _scheduleH1Color = Color(0xFFEF4444);
  static const _cosmeticsColor = Color(0xFFBC8F8F);

  static const _gradientPrimary = LinearGradient(
    colors: [_primary, Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final _darkColors = AppColorsExtension(
    primary: _primary,
    primaryDark: _primaryDark,
    primaryLight: _primaryLight,
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceElevated: Color(0xFF1E2530),
    surfaceBorder: Color(0xFF30363D),
    textPrimary: Color(0xFFE6EDF3),
    textSecondary: Color(0xFF8B949E),
    textMuted: Color(0xFF484F58),
    success: _success,
    warning: _warning,
    error: _error,
    info: _info,
    otcColor: _otcColor,
    rxColor: _rxColor,
    scheduleHColor: _scheduleHColor,
    scheduleH1Color: _scheduleH1Color,
    cosmeticsColor: _cosmeticsColor,
    expiryGood: _success,
    expiryWarning: _warning,
    expiryCritical: _error,
    gradientPrimary: _gradientPrimary,
    gradientCard: LinearGradient(
      colors: [Color(0xFF1E2530), Color(0xFF161B22)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static final _lightColors = AppColorsExtension(
    primary: _primary,
    primaryDark: _primaryDark,
    primaryLight: _primaryLight,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceBorder: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1E293B), // Dark slate
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    success: _success,
    warning: _warning,
    error: _error,
    info: _info,
    otcColor: _otcColor,
    rxColor: _rxColor,
    scheduleHColor: _scheduleHColor,
    scheduleH1Color: _scheduleH1Color,
    cosmeticsColor: _cosmeticsColor,
    expiryGood: _success,
    expiryWarning: _warning,
    expiryCritical: _error,
    gradientPrimary: _gradientPrimary,
    gradientCard: LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return _buildTheme(base, _darkColors);
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return _buildTheme(base, _lightColors);
  }

  static ThemeData _buildTheme(ThemeData base, AppColorsExtension colors) {
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.error,
        onPrimary: Colors.black,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: colors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                color: colors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600);
          }
          return GoogleFonts.inter(
              color: colors.textMuted, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 22);
          }
          return IconThemeData(color: colors.textMuted, size: 22);
        }),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.surfaceBorder, width: 1),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.surfaceBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.surfaceBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        hintStyle:
            GoogleFonts.inter(color: colors.textMuted, fontSize: 16, fontWeight: FontWeight.w500),
        labelStyle:
            GoogleFonts.inter(color: colors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(88, 52), // 52px minimum height
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          minimumSize: Size(88, 52), // 52px minimum height
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceElevated,
        labelStyle:
            GoogleFonts.inter(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500), // Medium for filters
        side: BorderSide(color: colors.surfaceBorder, width: 2), // 2px border
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), // To hit 52px minimum height ideally
      ),
      dividerTheme: DividerThemeData(
        color: colors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceElevated,
        contentTextStyle:
            GoogleFonts.inter(color: colors.textPrimary, fontSize: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
