import 'brand_theme_config.dart';

class RentalListing {
  final String id;
  final String hostName;
  final bool hostVerified;
  final double hostRating;
  final int tripCount;
  final String vehicleTitle;
  final CarBrandId brandId;
  final PowertrainType powertrain;
  final String transmission;
  final int year;
  final int hourlyPriceTry;
  final int dailyPriceTry;
  final int depositTry;
  final int dailyKmLimit;
  final double distanceKm;
  final String neighborhood;
  final int fuelOrBatteryPercent;
  final bool instantKeylessUnlock;
  final double mapX;
  final double mapY;
  final List<String> features;

  const RentalListing({
    required this.id,
    required this.hostName,
    required this.hostVerified,
    required this.hostRating,
    required this.tripCount,
    required this.vehicleTitle,
    required this.brandId,
    required this.powertrain,
    required this.transmission,
    required this.year,
    required this.hourlyPriceTry,
    required this.dailyPriceTry,
    required this.depositTry,
    required this.dailyKmLimit,
    required this.distanceKm,
    required this.neighborhood,
    required this.fuelOrBatteryPercent,
    required this.instantKeylessUnlock,
    required this.mapX,
    required this.mapY,
    required this.features,
  });
}
