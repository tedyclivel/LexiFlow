import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LexiFlow Design System - Typography
class LexiTextStyles {
  // Display Text (Large titles, scores)
  static TextStyle display({
    Color color = Colors.white,
    double fontSize = 72,
    FontWeight weight = FontWeight.w900,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: -1.5,
      height: 1.0,
      shadows: [
        Shadow(
          offset: const Offset(0, 4),
          blurRadius: 8,
          color: Colors.black.withOpacity(0.3),
        ),
        Shadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  // Heading Text (Section titles)
  static TextStyle heading({
    Color color = Colors.white,
    double fontSize = 32,
    FontWeight weight = FontWeight.w800,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.5,
      shadows: [
        Shadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          color: Colors.black.withOpacity(0.2),
        ),
      ],
    );
  }

  // Button Text
  static TextStyle button({
    Color color = Colors.white,
    double fontSize = 18,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.2,
    );
  }

  // Body Text
  static TextStyle body({
    Color color = const Color(0xFF64748B),
    double fontSize = 16,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
    );
  }

  // Label Text (Small, uppercase)
  static TextStyle label({
    Color color = const Color(0xFF94A3B8),
    double fontSize = 12,
    FontWeight weight = FontWeight.w800,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      letterSpacing: 1.5,
    );
  }
}

/// LexiFlow Design System - Colors
class LexiColors {
  // Primary
  static const primaryBlue = Color(0xFF1E3A8A);
  static const primaryBlueDark = Color(0xFF0D47A1);
  static const primaryBlueLight = Color(0xFF3B82F6);

  // Accent
  static const accentTeal = Color(0xFF2DD4BF);
  static const accentTealDark = Color(0xFF14B8A6);
  static const accentOrange = Color(0xFFFF9500);
  static const accentPurple = Color(0xFFA855F7);
  static const accentGreen = Color(0xFF00C853);
  static const accentCyan = Color(0xFF00E5FF);

  // Neutral
  static const white = Color(0xFFFFFFFF);
  static const gray50 = Color(0xFFF8FAFC);
  static const gray100 = Color(0xFFF1F5F9);
  static const gray200 = Color(0xFFE2E8F0);
  static const gray400 = Color(0xFF94A3B8);
  static const gray600 = Color(0xFF64748B);
  static const gray800 = Color(0xFF1E293B);

  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, primaryBlueLight],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentTeal, accentTealDark],
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
  );
}

/// Gradient Text Widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

/// LexiFlow Responsive Helper
/// Use these helpers instead of hardcoded pixel values to ensure the UI
/// adapts to any screen size (small phones, large phones, tablets).
class R {
  R._();

  // --- Breakpoints ---
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  // --- Font sizes ---
  /// Scale a base font size relative to screen width (320→clamp→small, 400→base, 600+→large).
  static double fs(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    final scale = (w / 400).clamp(0.80, 1.35);
    return (base * scale).roundToDouble();
  }

  // --- Spacing / padding ---
  /// Scale a spacing value relative to screen height.
  static double sp(BuildContext context, double base) {
    final h = MediaQuery.of(context).size.height;
    final scale = (h / 800).clamp(0.75, 1.40);
    return (base * scale).roundToDouble();
  }

  // --- Adaptive values ---
  /// Returns [mobile] on phones, [tablet] on tablets.
  static T adaptive<T>(BuildContext context, {required T mobile, required T tablet}) =>
      isTablet(context) ? tablet : mobile;

  // --- Grid columns ---
  static int gridCols(BuildContext context, {int mobile = 2, int tablet = 3}) =>
      isTablet(context) ? tablet : mobile;

  // --- Fraction of screen ---
  static double sw(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.width * fraction;

  static double sh(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.height * fraction;
}
