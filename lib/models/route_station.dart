enum StationCategory {
  evCharger,
  fuelStation,
}

class RouteStation {
  final String id;
  final String name;
  final String operatorBrand; // Trugo, Tesla Supercharger, ZES, Shell, Opet, PO
  final StationCategory category;
  final double distanceAlongRouteKm;
  final int detourMinutes;
  final double mapX;
  final double mapY;

  // EV specific
  final int? maxPowerKw;
  final String? connectorTypes; // CCS2 250kW, Type 2 22kW
  final int? availableStalls;
  final int? totalStalls;
  final double? pricePerKwhTry;
  final int? estimatedArrivalSocPercent;

  // Fuel specific
  final double? gasoline95PriceTry;
  final double? dieselPriceTry;
  final double? lpgPriceTry;
  final bool hasHighOctanePerformanceFuel;

  final List<String> amenities;

  const RouteStation({
    required this.id,
    required this.name,
    required this.operatorBrand,
    required this.category,
    required this.distanceAlongRouteKm,
    required this.detourMinutes,
    required this.mapX,
    required this.mapY,
    this.maxPowerKw,
    this.connectorTypes,
    this.availableStalls,
    this.totalStalls,
    this.pricePerKwhTry,
    this.estimatedArrivalSocPercent,
    this.gasoline95PriceTry,
    this.dieselPriceTry,
    this.lpgPriceTry,
    this.hasHighOctanePerformanceFuel = false,
    required this.amenities,
  });
}

class NavigationCorridor {
  final String id;
  final String originName;
  final String destinationName;
  final double totalDistanceKm;
  final int durationMinutes;
  final String highwaySummary;
  final List<RouteStation> stations;

  const NavigationCorridor({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.totalDistanceKm,
    required this.durationMinutes,
    required this.highwaySummary,
    required this.stations,
  });
}
