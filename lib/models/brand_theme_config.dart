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

  ThemeData toMaterialTheme() {
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF3F5F9),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceColor,
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor.withValues(alpha: 0.94),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        indicatorColor: primaryColor.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: primaryColor.withValues(alpha: 0.26),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
