import 'package:flutter/material.dart';

enum CarBrandId {
  tesla,
  bmw,
  togg,
  mercedes,
  porsche,
  audi,
}

enum PowertrainType {
  electric,
  gasoline,
  diesel,
  hybrid,
}

extension PowertrainTypeX on PowertrainType {
  bool get isElectric => this == PowertrainType.electric;

  String get labelTr {
    switch (this) {
      case PowertrainType.electric:
        return 'Tam Elektrikli (BEV)';
      case PowertrainType.gasoline:
        return 'Benzinli (ICE)';
      case PowertrainType.diesel:
        return 'Dizel (TDI/d)';
      case PowertrainType.hybrid:
        return 'Şarj Edilebilir Hibrit (PHEV)';
    }
  }
}

class BrandThemeConfig {
  final CarBrandId id;
  final String name;
  final String shortCode;
  final String slogan;
  final String dynamicIconKey; // iOS alternate icon & Android activity-alias key
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color glowColor;
  final PowertrainType defaultPowertrain;

  const BrandThemeConfig({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.slogan,
    required this.dynamicIconKey,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.glowColor,
    required this.defaultPowertrain,
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
        backgroundColor: surfaceColor.withValues(alpha: 0.92),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: primaryColor.withValues(alpha: 0.24),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12.5),
      ),
    );
  }
}
