import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/live_api_models.dart';

class LiveOsmCockpitMap extends StatefulWidget {
  final LatLng userLocation;
  final LatLng? destinationPoint;
  final List<LatLng> routePolyline;
  final List<LivePoiItem> pois;
  final Color accentColor;
  final bool darkTiles;
  final double initialZoom;
  final ValueChanged<LivePoiItem>? onPoiTap;
  final VoidCallback? onToggleTileStyle;
  final VoidCallback? onRecenterGps;

  const LiveOsmCockpitMap({
    super.key,
    required this.userLocation,
    this.destinationPoint,
    this.routePolyline = const [],
    this.pois = const [],
    required this.accentColor,
    this.darkTiles = true,
    this.initialZoom = 12.2,
    this.onPoiTap,
    this.onToggleTileStyle,
    this.onRecenterGps,
  });

  @override
  State<LiveOsmCockpitMap> createState() => _LiveOsmCockpitMapState();
}

class _LiveOsmCockpitMapState extends State<LiveOsmCockpitMap> {
  final MapController _mapController = MapController();

  // Official invert + 180° hue-rotation cockpit dark matrix (preserves blue seas & green parks)
  static const ColorFilter _darkCockpitMatrix = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255,
    -0.426, -0.430, -0.144, 0, 255,
    -0.426, -1.430, 0.856, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  @override
  void didUpdateWidget(covariant LiveOsmCockpitMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLocation != widget.userLocation) {
      try {
        _mapController.move(widget.userLocation, widget.initialZoom);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTileLayer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.otonom.otonom',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF080D16),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.45),
            width: 1.4,
          ),
        ),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.userLocation,
                initialZoom: widget.initialZoom,
              ),
              children: [
                if (widget.darkTiles)
                  ColorFiltered(
                    colorFilter: _darkCockpitMatrix,
                    child: baseTileLayer,
                  )
                else
                  baseTileLayer,
                if (widget.routePolyline.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePolyline,
                        strokeWidth: 9.0,
                        color: widget.accentColor.withValues(alpha: 0.32),
                      ),
                      Polyline(
                        points: widget.routePolyline,
                        strokeWidth: 4.5,
                        color: widget.accentColor,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    for (final poi in widget.pois)
                      Marker(
                        point: poi.point,
                        width: 122,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => widget.onPoiTap?.call(poi),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xEE0F172A),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _poiBorderColor(poi.category),
                                width: 1.4,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black54, blurRadius: 6),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _poiIcon(poi.category),
                                  size: 13,
                                  color: _poiBorderColor(poi.category),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${poi.distanceKm.toStringAsFixed(1)}km · ${poi.brandOrOperator}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.destinationPoint != null)
                      Marker(
                        point: widget.destinationPoint!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.accentColor,
                            border: Border.all(color: Colors.white, width: 2.2),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    Marker(
                      point: widget.userLocation,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.65),
                              blurRadius: 14,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Column(
                children: [
                  _MapSmallFab(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Canlı GPS Konumuma Odakla',
                    onTap: () {
                      _mapController.move(widget.userLocation, 13.5);
                      widget.onRecenterGps?.call();
                    },
                  ),
                  const SizedBox(height: 8),
                  if (widget.onToggleTileStyle != null)
                    _MapSmallFab(
                      icon: widget.darkTiles
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      tooltip: 'Koyu / Açık Harita',
                      onTap: widget.onToggleTileStyle!,
                    ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.darkTiles
                      ? '© OpenStreetMap · Koyu Kokpit Modu'
                      : '© OpenStreetMap · Gündüz Modu',
                  style: const TextStyle(fontSize: 9.5, color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _poiBorderColor(String category) {
    switch (category) {
      case 'ev':
        return const Color(0xFF22D3EE);
      case 'fuel':
        return const Color(0xFFFBBF24);
      case 'tow_repair':
        return const Color(0xFFF97316);
      case 'car_rental':
        return const Color(0xFF34D399);
      default:
        return Colors.white;
    }
  }

  IconData _poiIcon(String category) {
    switch (category) {
      case 'ev':
        return Icons.bolt_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'tow_repair':
        return Icons.build_circle_rounded;
      case 'car_rental':
        return Icons.car_rental_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

class _MapSmallFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapSmallFab({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xDD0F172A),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19, color: Colors.white),
        ),
      ),
    );
  }
}
