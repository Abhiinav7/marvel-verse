import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarvelColors {
  static const red = Color(0xFFE62429);
  static const deepRed = Color(0xFF8B0000);
  static const gold = Color(0xFFF7B32B);
  static const blue = Color(0xFF1E6FFF);
  static const purple = Color(0xFF7B2FF7);
  static const cyan = Color(0xFF00E5FF);
  static const green = Color(0xFF2ECC71);
  static const bg = Color(0xFF0B0B12);
  static const surface = Color(0xFF16161F);
  static const surfaceHigh = Color(0xFF20202C);
  static const textDim = Color(0xFF9A9AB0);

  static const heroGradient = LinearGradient(
    colors: [red, Color(0xFFB0122A), purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Infinity-stone palette, used to colour-code phases.
  static const phaseColors = <int, Color>{
    1: Color(0xFF1E6FFF), // Space
    2: Color(0xFFF7B32B), // Mind
    3: Color(0xFFE62429), // Reality
    4: Color(0xFF7B2FF7), // Power
    5: Color(0xFF2ECC71), // Time
    6: Color(0xFFFF7A00), // Soul
  };

  static Color phase(int p) => phaseColors[p] ?? red;
}

class AppTheme {
  static TextStyle display(double size, {Color color = Colors.white}) =>
      GoogleFonts.bebasNeue(fontSize: size, color: color, letterSpacing: 1.2);

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MarvelColors.red,
        brightness: Brightness.dark,
        primary: MarvelColors.red,
        secondary: MarvelColors.gold,
        surface: MarvelColors.surface,
      ),
      scaffoldBackgroundColor: MarvelColors.bg,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display(28),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: MarvelColors.surfaceHigh,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MarvelColors.surface,
        indicatorColor: MarvelColors.red.withValues(alpha: 0.25),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
