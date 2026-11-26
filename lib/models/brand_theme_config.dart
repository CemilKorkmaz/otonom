import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CarBrandId {
  tesla,
  bmw,
  togg,
  mercedes,
  porsche,
  audi,
  other,
}

enum PowertrainType {
  electric,
  gasoline,
  diesel,
  hybrid,
  lpg,
}

extension PowertrainTypeX on PowertrainType {
  bool get isElectric => this == PowertrainType.electric;

  String get labelTr {
    switch (this) {
      case PowertrainType.electric:
        return 'Tam Elektrikli (BEV)';
      case PowertrainType.gasoline:
        return 'Benzinli';
      case PowertrainType.diesel:
        return 'Dizel';
      case PowertrainType.hybrid:
        return 'Hibrit (HEV / PHEV)';
      case PowertrainType.lpg:
        return 'Benzin & LPG';
    }
  }

  String get shortFuelTag {
    switch (this) {
      case PowertrainType.electric:
        return 'Elektrik';
      case PowertrainType.gasoline:
        return 'Benzin';
      case PowertrainType.diesel:
        return 'Dizel';
      case PowertrainType.hybrid:
        return 'Hibrit';
      case PowertrainType.lpg:
        return 'LPG';
    }
  }
}

class BrandThemeConfig {
  final CarBrandId id;
  final String brandKey;
  final String name;
  final String shortCode;
  final String slogan;
  final String dynamicIconKey;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color glowColor;
  final PowertrainType defaultPowertrain;

  String get brandName => name;

  const BrandThemeConfig({
    this.id = CarBrandId.other,
    this.brandKey = 'otonom',
    required this.name,
    required this.shortCode,
    required this.slogan,
    required this.dynamicIconKey,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.glowColor,
    this.defaultPowertrain = PowertrainType.gasoline,
  });

  /// Builds an iPhone / iOS Cupertino-inspired dark Liquid-Glass Material+Cupertino theme
  ThemeData toMaterialTheme() {
    const iosBlack = Color(0xFF000000);
    const iosElevatedCard = Color(0xFF1C1C1E);

    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: iosBlack,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF5F5F7),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: iosBlack,
      cardColor: iosElevatedCard,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.white.withValues(alpha: 0.06),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        barBackgroundColor: const Color(0xB8161618),
        scaffoldBackgroundColor: iosBlack,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: iosElevatedCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.09),
            width: 0.65,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2E),
        selectedColor: primaryColor.withValues(alpha: 0.30),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
