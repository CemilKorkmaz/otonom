import 'package:latlong2/latlong.dart';

class ApiEndpointStatus {
  final String id;
  final String name;
  final String provider;
  final bool online;
  final int latencyMs;
  final String summary;
  final DateTime updatedAt;

  const ApiEndpointStatus({
    required this.id,
    required this.name,
    required this.provider,
    required this.online,
    required this.latencyMs,
    required this.summary,
    required this.updatedAt,
  });
}

class LivePlaceSearchResult {
  final String displayName;
  final String shortName;
  final LatLng point;

  const LivePlaceSearchResult({
    required this.displayName,
    required this.shortName,
    required this.point,
  });
}

class LiveRoadWeather {
  final double temperatureC;
  final double apparentTempC;
  final double windSpeedKmh;
  final double precipitationMm;
  final int weatherCode;
  final String conditionTr;
  final String drivingAdvisoryTr;

  const LiveRoadWeather({
    required this.temperatureC,
    required this.apparentTempC,
    required this.windSpeedKmh,
    required this.precipitationMm,
    required this.weatherCode,
    required this.conditionTr,
    required this.drivingAdvisoryTr,
  });
}

enum NavTurnKind {
  depart,
  straight,
  slightLeft,
  left,
  sharpLeft,
  slightRight,
  right,
  sharpRight,
  uTurn,
  roundabout,
  merge,
  ramp,
  arrive,
}

class LiveNavManeuverStep {
  final LatLng location;
  final String roadName;
  final String instructionTr;
  final NavTurnKind turnKind;
  final double distanceMeters;
  final double durationSeconds;

  const LiveNavManeuverStep({
    required this.location,
    required this.roadName,
    required this.instructionTr,
    required this.turnKind,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class LiveOsrmRoute {
  final List<LatLng> polyline;
  final double distanceKm;
  final int durationMinutes;
  final List<String> stepInstructions;
  final List<LiveNavManeuverStep> maneuvers;

  const LiveOsrmRoute({
    required this.polyline,
    required this.distanceKm,
    required this.durationMinutes,
    required this.stepInstructions,
    this.maneuvers = const [],
  });
}

class LivePoiItem {
  final String id;
  final String name;
  final String brandOrOperator;
  final String category; // 'ev' | 'fuel' | 'tow_repair' | 'car_rental'
  final LatLng point;
  final double distanceKm;
  final String? phone;
  final String? address;
  final String subtitle;
  final List<String> tags;

  const LivePoiItem({
    required this.id,
    required this.name,
    required this.brandOrOperator,
    required this.category,
    required this.point,
    required this.distanceKm,
    this.phone,
    this.address,
    required this.subtitle,
    required this.tags,
  });
}

class LiveEpaVehicleSpec {
  final String id;
  final String make;
  final String model;
  final String year;
  final String trimDescription;
  final String cylinders;
  final String displacementL;
  final String drive;
  final String transmission;
  final String fuelType;
  final String combinedConsumption;
  final String cityConsumption;
  final String highwayConsumption;
  final String co2GramsPerKm;

  const LiveEpaVehicleSpec({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.trimDescription,
    required this.cylinders,
    required this.displacementL,
    required this.drive,
    required this.transmission,
    required this.fuelType,
    required this.combinedConsumption,
    required this.cityConsumption,
    required this.highwayConsumption,
    required this.co2GramsPerKm,
  });
}

class LiveRecallItem {
  final String campaignNumber;
  final String component;
  final String summary;
  final String consequence;
  final String remedy;
  final String reportDate;

  const LiveRecallItem({
    required this.campaignNumber,
    required this.component,
    required this.summary,
    required this.consequence,
    required this.remedy,
    required this.reportDate,
  });
}

class LiveComplaintItem {
  final String odiNumber;
  final String components;
  final String summary;
  final bool crash;
  final bool fire;
  final String dateIncident;

  const LiveComplaintItem({
    required this.odiNumber,
    required this.components,
    required this.summary,
    required this.crash,
    required this.fire,
    required this.dateIncident,
  });
}

class LiveWikipediaVehicleSummary {
  final String title;
  final String extract;
  final String? imageUrl;
  final String? pageUrl;

  const LiveWikipediaVehicleSummary({
    required this.title,
    required this.extract,
    this.imageUrl,
    this.pageUrl,
  });
}
