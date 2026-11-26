import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/route_station.dart';
import '../models/tow_truck.dart';
import '../models/rental_listing.dart';

enum CockpitMapMode {
  navigation,
  towRadar,
  rentalMap,
}

class InteractiveCockpitMap extends StatelessWidget {
  final CockpitMapMode mode;
  final Color accentColor;
  final bool isElectric;
  final double routeProgress;
  final List<RouteStation> stations;
  final Set<String> waypointIds;
  final ValueChanged<RouteStation>? onStationTap;
  final List<TowTruckOperator> towTrucks;
  final ValueChanged<TowTruckOperator>? onTowTruckTap;
  final List<RentalListing> rentals;
  final ValueChanged<RentalListing>? onRentalTap;

  const InteractiveCockpitMap({
    super.key,
    required this.mode,
    required this.accentColor,
    this.isElectric = true,
    this.routeProgress = 0.15,
    this.stations = const [],
    this.waypointIds = const {},
    this.onStationTap,
    this.towTrucks = const [],
    this.onTowTruckTap,
    this.rentals = const [],
    this.onRentalTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF080D16),
          border: Border.all(color: accentColor.withValues(alpha: 0.35), width: 1.2),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 2.8,
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _VectorCockpitMapPainter(
                          mode: mode,
                          accentColor: accentColor,
                          routeProgress: routeProgress,
                        ),
                      ),
                    ),
                    if (mode == CockpitMapMode.navigation) ...[
                      // Origin & Destination tags
                      Positioned(
                        left: width * 0.08,
                        top: height * 0.24,
                        child: _MapEndpointTag(
                          label: 'Başlangıç',
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: width * 0.80,
                        top: height * 0.72,
                        child: _MapEndpointTag(
                          label: 'Varış',
                          color: accentColor,
                        ),
                      ),
                      // Station markers along route
                      for (final station in stations)
                        Positioned(
                          left: (width * station.mapX - 44).clamp(6.0, width - 96),
                          top: (height * station.mapY - 18).clamp(6.0, height - 42),
                          child: GestureDetector(
                            onTap: () => onStationTap?.call(station),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: waypointIds.contains(station.id)
                                    ? accentColor
                                    : const Color(0xEB111827),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isElectric
                                      ? const Color(0xFF22D3EE)
                                      : const Color(0xFFF59E0B),
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isElectric
                                        ? Icons.bolt_rounded
                                        : Icons.local_gas_station_rounded,
                                    size: 14,
                                    color: isElectric
                                        ? const Color(0xFF22D3EE)
                                        : const Color(0xFFFBBF24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isElectric
                                        ? '${station.maxPowerKw}kW · ${station.distanceAlongRouteKm.toStringAsFixed(0)}km'
                                        : '₺${station.gasoline95PriceTry?.toStringAsFixed(1)} · ${station.distanceAlongRouteKm.toStringAsFixed(0)}km',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                    if (mode == CockpitMapMode.towRadar) ...[
                      // User center pin
                      Positioned(
                        left: width * 0.5 - 18,
                        top: height * 0.5 - 18,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      for (final truck in towTrucks)
                        Positioned(
                          left: (width * truck.mapX - 42).clamp(8.0, width - 95),
                          top: (height * truck.mapY - 18).clamp(8.0, height - 42),
                          child: GestureDetector(
                            onTap: () => onTowTruckTap?.call(truck),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xEE18181B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 1.4,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.fire_truck_rounded,
                                    size: 14,
                                    color: Color(0xFFFBBF24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${truck.etaMinutes} dk · ${truck.distanceKm} km',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                    if (mode == CockpitMapMode.rentalMap) ...[
                      for (final item in rentals)
                        Positioned(
                          left: (width * item.mapX - 42).clamp(8.0, width - 96),
                          top: (height * item.mapY - 18).clamp(8.0, height - 42),
                          child: GestureDetector(
                            onTap: () => onRentalTap?.call(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.white, width: 1.3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                '₺${item.dailyPriceTry}/gün',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MapEndpointTag extends StatelessWidget {
  final String label;
  final Color color;

  const _MapEndpointTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _VectorCockpitMapPainter extends CustomPainter {
  final CockpitMapMode mode;
  final Color accentColor;
  final double routeProgress;

  const _VectorCockpitMapPainter({
    required this.mode,
    required this.accentColor,
    required this.routeProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle dark road grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Stylized Sea of Marmara / Bosphorus water polygon
    final waterPath = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.48,
        size.width * 0.42,
        size.height * 0.68,
      )
      ..lineTo(0, size.height * 0.88)
      ..close();
    canvas.drawPath(
      waterPath,
      Paint()..color = const Color(0xFF0C223B).withValues(alpha: 0.65),
    );

    // Secondary arterial roads
    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final arterial1 = Path()
      ..moveTo(0, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.35,
        size.width,
        size.height * 0.18,
      );
    final arterial2 = Path()
      ..moveTo(size.width * 0.18, 0)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.55,
        size.width * 0.72,
        size.height,
      );
    canvas.drawPath(arterial1, roadPaint);
    canvas.drawPath(arterial2, roadPaint);

    if (mode == CockpitMapMode.navigation) {
      final routePath = Path()
        ..moveTo(size.width * 0.12, size.height * 0.32)
        ..cubicTo(
          size.width * 0.35,
          size.height * 0.38,
          size.width * 0.62,
          size.height * 0.45,
          size.width * 0.88,
          size.height * 0.70,
        );

      // Glow aura
      canvas.drawPath(
        routePath,
        Paint()
          ..color = accentColor.withValues(alpha: 0.32)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 11,
      );
      // Main route line
      canvas.drawPath(
        routePath,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4.2,
      );

      // Live vehicle position along route metric
      final metrics = routePath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final tangent =
            metric.getTangentForOffset(metric.length * routeProgress.clamp(0.0, 1.0));
        if (tangent != null) {
          canvas.drawCircle(
            tangent.position,
            12,
            Paint()..color = accentColor.withValues(alpha: 0.35),
          );
          canvas.drawCircle(
            tangent.position,
            6.5,
            Paint()..color = Colors.white,
          );
        }
      }
    } else if (mode == CockpitMapMode.towRadar) {
      final center = Offset(size.width * 0.5, size.height * 0.5);
      final maxR = math.min(size.width, size.height) * 0.44;
      for (final f in [0.33, 0.66, 1.0]) {
        canvas.drawCircle(
          center,
          maxR * f,
          Paint()
            ..color = const Color(0xFFF59E0B).withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VectorCockpitMapPainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.routeProgress != routeProgress;
  }
}
