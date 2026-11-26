import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/live_api_models.dart';
import '../services/emergency_service.dart';
import '../services/live_apis_service.dart';
import '../state/app_state.dart';
import '../widgets/ios_liquid_glass.dart';

class FullscreenTurnByTurnScreen extends StatefulWidget {
  final OtonomAppState appState;
  final LiveOsrmRoute initialRoute;
  final String destinationTitle;
  final LatLng destinationPoint;

  const FullscreenTurnByTurnScreen({
    super.key,
    required this.appState,
    required this.initialRoute,
    required this.destinationTitle,
    required this.destinationPoint,
  });

  @override
  State<FullscreenTurnByTurnScreen> createState() =>
      _FullscreenTurnByTurnScreenState();
}

class _FullscreenTurnByTurnScreenState
    extends State<FullscreenTurnByTurnScreen> {
  static const double _drivingZoom = 17.3;
  static const ColorFilter _darkCockpitMatrix = ColorFilter.matrix(<double>[
    0.574, -1.430, -0.144, 0, 255,
    -0.426, -0.430, -0.144, 0, 255,
    -0.426, -1.430, 0.856, 0, 255,
    0, 0, 0, 1, 0,
  ]);

  final MapController _mapController = MapController();

  late LiveOsrmRoute _route;
  late LatLng _carPosition;
  double _headingDeg = 0.0;
  double _speedKmh = 0.0;

  int _currentStepIndex = 0;
  double _distanceToNextTurnMeters = 0.0;
  double _remainingDistanceKm = 0.0;
  int _remainingMinutes = 1;

  bool _followCamera = true;
  bool _headingUpMode = true;
  bool _showPoisOnMap = true;
  bool _showAllStepsSheet = false;
  bool _simulating = false;
  bool _rerouting = false;
  bool _arrived = false;

  StreamSubscription<Position>? _gpsSub;
  Timer? _simTimer;
  int _simPolylineIndex = 0;
  double _simSegmentFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _route = widget.initialRoute;
    _carPosition = _route.polyline.isNotEmpty
        ? _route.polyline.first
        : widget.appState.currentLocation;

    if (_route.polyline.length >= 2) {
      _headingDeg = LiveApisService.bearingDegrees(
        _route.polyline[0],
        _route.polyline[1],
      );
    }

    _recomputeProgress();
    unawaited(_startRealGpsTracking());

    // Snap camera into close-up Google/Apple Maps view after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncCameraToCar();
      }
    });
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _simTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRealGpsTracking() async {
    final stream = await widget.appState.liveApis.openLiveNavigationStream();
    if (!mounted || stream == null) return;

    _gpsSub = stream.listen((pos) {
      if (!mounted || _simulating) return;
      final newPt = LatLng(pos.latitude, pos.longitude);
      final rawSpeedKmh = math.max(0.0, pos.speed * 3.6);
      double nextHeading = _headingDeg;
      if (pos.heading >= 0 && pos.heading <= 360 && rawSpeedKmh > 3.0) {
        nextHeading = pos.heading;
      } else if (LiveApisService.haversineKm(_carPosition, newPt) > 0.004) {
        nextHeading = LiveApisService.bearingDegrees(_carPosition, newPt);
      }

      setState(() {
        _carPosition = newPt;
        _speedKmh = rawSpeedKmh;
        _headingDeg = nextHeading;
      });
      widget.appState.updateLivePositionFromNavigation(newPt);
      _recomputeProgress();
      if (_followCamera) {
        _syncCameraToCar();
      }
      _checkOffRouteAndReroute(newPt);
    });
  }

  void _toggleSimulation() {
    HapticFeedback.mediumImpact();
    if (_simulating) {
      _simTimer?.cancel();
      setState(() {
        _simulating = false;
        _speedKmh = 0;
      });
      return;
    }

    if (_route.polyline.length < 2) return;
    setState(() {
      _simulating = true;
      _arrived = false;
      _followCamera = true;
      if (_simPolylineIndex >= _route.polyline.length - 1) {
        _simPolylineIndex = 0;
        _simSegmentFraction = 0.0;
        _currentStepIndex = 0;
      }
    });

    // Smooth ~65 km/h simulation (~4.5m per 250ms tick = 18 m/s = 64.8 km/h)
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (!mounted || !_simulating) {
        timer.cancel();
        return;
      }
      final pts = _route.polyline;
      if (_simPolylineIndex >= pts.length - 1) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _simulating = false;
          _speedKmh = 0;
          _arrived = true;
          _remainingDistanceKm = 0;
          _remainingMinutes = 0;
        });
        return;
      }

      final a = pts[_simPolylineIndex];
      final b = pts[_simPolylineIndex + 1];
      final segMeters = math.max(1.0, LiveApisService.haversineKm(a, b) * 1000.0);
      const stepMetersPerTick = 11.0; // Smooth visual cruise speed
      _simSegmentFraction += stepMetersPerTick / segMeters;

      while (_simSegmentFraction >= 1.0 && _simPolylineIndex < pts.length - 1) {
        _simSegmentFraction -= 1.0;
        _simPolylineIndex++;
        if (_simPolylineIndex < pts.length - 1) {
          final na = pts[_simPolylineIndex];
          final nb = pts[_simPolylineIndex + 1];
          final nextSeg =
              math.max(1.0, LiveApisService.haversineKm(na, nb) * 1000.0);
          _simSegmentFraction = _simSegmentFraction.clamp(0.0, 0.99);
          if (nextSeg > 0) break;
        }
      }

      if (_simPolylineIndex >= pts.length - 1) {
        setState(() {
          _carPosition = pts.last;
          _simulating = false;
          _speedKmh = 0;
          _arrived = true;
        });
        timer.cancel();
        return;
      }

      final p1 = pts[_simPolylineIndex];
      final p2 = pts[_simPolylineIndex + 1];
      final t = _simSegmentFraction.clamp(0.0, 1.0);
      final interpLat = p1.latitude + (p2.latitude - p1.latitude) * t;
      final interpLon = p1.longitude + (p2.longitude - p1.longitude) * t;
      final nextPos = LatLng(interpLat, interpLon);
      final brg = LiveApisService.bearingDegrees(p1, p2);

      setState(() {
        _carPosition = nextPos;
        _headingDeg = brg;
        _speedKmh = 68.0 + math.sin(_simPolylineIndex * 0.4) * 9.0;
      });
      _recomputeProgress();
      if (_followCamera) {
        _syncCameraToCar();
      }
    });
  }

  void _syncCameraToCar() {
    try {
      // Negative Y offset shifts car toward lower half of screen so road ahead fills top 70%!
      _mapController.move(
        _carPosition,
        _drivingZoom,
        offset: const Offset(0, 95),
      );
      _mapController.rotate(_headingUpMode ? -_headingDeg : 0.0);
    } on Object {
      // Safe before FlutterMap finishes first layout
    }
  }

  void _recomputeProgress() {
    final maneuvers = _route.maneuvers;
    if (maneuvers.isNotEmpty) {
      if (_currentStepIndex >= maneuvers.length) {
        _currentStepIndex = maneuvers.length - 1;
      }
      // Skip initial 'depart' step immediately so user sees the upcoming turn!
      if (_currentStepIndex == 0 &&
          maneuvers.length > 1 &&
          maneuvers.first.turnKind == NavTurnKind.depart) {
        _currentStepIndex = 1;
      }

      final stepTarget = maneuvers[_currentStepIndex].location;
      final distM = LiveApisService.haversineKm(_carPosition, stepTarget) * 1000.0;
      _distanceToNextTurnMeters = distM;

      if (distM < 36.0 && _currentStepIndex < maneuvers.length - 1) {
        HapticFeedback.lightImpact();
        _currentStepIndex++;
        _distanceToNextTurnMeters = LiveApisService.haversineKm(
              _carPosition,
              maneuvers[_currentStepIndex].location,
            ) *
            1000.0;
      }
    }

    // Remaining distance along polyline from nearest vertex to destination
    if (_route.polyline.length >= 2) {
      int closestIdx = 0;
      double bestKm = double.infinity;
      for (int i = 0; i < _route.polyline.length; i++) {
        final d = LiveApisService.haversineKm(_carPosition, _route.polyline[i]);
        if (d < bestKm) {
          bestKm = d;
          closestIdx = i;
        }
      }
      double remKm = bestKm;
      for (int i = closestIdx; i < _route.polyline.length - 1; i++) {
        remKm += LiveApisService.haversineKm(
          _route.polyline[i],
          _route.polyline[i + 1],
        );
      }
      _remainingDistanceKm = remKm;
      final ratio = _route.distanceKm > 0.05
          ? (remKm / _route.distanceKm).clamp(0.0, 1.2)
          : 0.0;
      _remainingMinutes =
          math.max(1, (_route.durationMinutes * ratio).round());
      if (remKm < 0.045) {
        _arrived = true;
        _remainingMinutes = 0;
      }
    } else {
      _remainingDistanceKm =
          LiveApisService.haversineKm(_carPosition, widget.destinationPoint);
    }
  }

  Future<void> _checkOffRouteAndReroute(LatLng pt) async {
    if (_rerouting || _route.polyline.isEmpty) return;
    double minKm = double.infinity;
    for (final p in _route.polyline) {
      final d = LiveApisService.haversineKm(pt, p);
      if (d < minKm) minKm = d;
    }
    // Reroute automatically if driver deviates by > 150 meters
    if (minKm > 0.15) {
      setState(() => _rerouting = true);
      final updated = await widget.appState.liveApis.fetchDrivingRoute(
        pt,
        widget.destinationPoint,
      );
      if (!mounted) return;
      if (updated != null && updated.polyline.length >= 2) {
        HapticFeedback.mediumImpact();
        setState(() {
          _route = updated;
          _currentStepIndex = updated.maneuvers.length > 1 ? 1 : 0;
          _rerouting = false;
        });
        _recomputeProgress();
      } else {
        setState(() => _rerouting = false);
      }
    }
  }

  String _formatTurnDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000.0).toStringAsFixed(1)} km';
    }
    final rounded = ((meters / 10).round() * 10).clamp(10, 990);
    return '$rounded m';
  }

  String _formatArrivalTime(int remainingMins) {
    final arrival = DateTime.now().add(Duration(minutes: remainingMins));
    final hh = arrival.hour.toString().padLeft(2, '0');
    final mm = arrival.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  IconData _turnIcon(NavTurnKind kind) {
    switch (kind) {
      case NavTurnKind.left:
        return Icons.turn_left_rounded;
      case NavTurnKind.slightLeft:
        return Icons.turn_slight_left_rounded;
      case NavTurnKind.sharpLeft:
        return Icons.turn_sharp_left_rounded;
      case NavTurnKind.right:
        return Icons.turn_right_rounded;
      case NavTurnKind.slightRight:
        return Icons.turn_slight_right_rounded;
      case NavTurnKind.sharpRight:
        return Icons.turn_sharp_right_rounded;
      case NavTurnKind.uTurn:
        return Icons.u_turn_left_rounded;
      case NavTurnKind.roundabout:
        return Icons.roundabout_right_rounded;
      case NavTurnKind.merge:
        return Icons.merge_rounded;
      case NavTurnKind.ramp:
        return Icons.ramp_right_rounded;
      case NavTurnKind.arrive:
        return Icons.flag_circle_rounded;
      case NavTurnKind.depart:
      case NavTurnKind.straight:
        return Icons.straight_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final brand = appState.brandTheme;
    final darkTiles = appState.darkMapTiles;
    final isEv = appState.isElectricVehicle;
    final pois = _showPoisOnMap ? appState.liveRouteStations : const <LivePoiItem>[];

    final maneuvers = _route.maneuvers;
    final currentManeuver = maneuvers.isNotEmpty
        ? maneuvers[_currentStepIndex.clamp(0, maneuvers.length - 1)]
        : null;
    final nextManeuver = (maneuvers.length > _currentStepIndex + 1)
        ? maneuvers[_currentStepIndex + 1]
        : null;

    final baseTileLayer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.otonom.otonom',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. 100% EDGE-TO-EDGE FULLSCREEN NAVIGATION MAP
          Positioned.fill(
            child: RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _carPosition,
                  initialZoom: _drivingZoom,
                  onPositionChanged: (_, hasGesture) {
                    if (hasGesture && _followCamera) {
                      setState(() => _followCamera = false);
                    }
                  },
                ),
                children: [
                  if (darkTiles)
                    ColorFiltered(
                      colorFilter: _darkCockpitMatrix,
                      child: baseTileLayer,
                    )
                  else
                    baseTileLayer,

                  // Vivid Google/Apple Maps Dual-Stroke Active Route Polyline
                  if (_route.polyline.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route.polyline,
                          strokeWidth: 14.0,
                          color: const Color(0xFF0A84FF).withValues(alpha: 0.34),
                        ),
                        Polyline(
                          points: _route.polyline,
                          strokeWidth: 7.5,
                          color: const Color(0xFF0A84FF),
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      // Optional EV / Fuel Station Pins along the route
                      for (final poi in pois.take(15))
                        Marker(
                          point: poi.point,
                          width: 42,
                          height: 42,
                          child: GestureDetector(
                            onTap: () => _showMidRoutePoiSheet(poi),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xEE1C1C1E),
                                border: Border.all(
                                  color: isEv
                                      ? const Color(0xFF32ADE6)
                                      : const Color(0xFFFFD60A),
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isEv
                                    ? Icons.bolt_rounded
                                    : Icons.local_gas_station_rounded,
                                size: 20,
                                color: isEv
                                    ? const Color(0xFF32ADE6)
                                    : const Color(0xFFFFD60A),
                              ),
                            ),
                          ),
                        ),

                      // Next Turn Highlight Dot
                      if (currentManeuver != null && !_arrived)
                        Marker(
                          point: currentManeuver.location,
                          width: 26,
                          height: 26,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFF0A84FF),
                                width: 4,
                              ),
                            ),
                          ),
                        ),

                      // Destination Checkered / Red Pin
                      Marker(
                        point: widget.destinationPoint,
                        width: 48,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF3B30),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 10),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.flag_fill,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),

                      // 3D Live Navigation Vehicle Chevron Puck
                      Marker(
                        point: _carPosition,
                        width: 68,
                        height: 68,
                        child: Transform.rotate(
                          // When map rotates (-heading), chevron points straight UP (0 rad)!
                          // When North-Up mode is active, chevron rotates to heading!
                          angle: _headingUpMode
                              ? 0.0
                              : (_headingDeg * math.pi / 180.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0A84FF)
                                      .withValues(alpha: 0.24),
                                ),
                              ),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFF0A84FF),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0A84FF)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.location_north_fill,
                                  color: Color(0xFF0A84FF),
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. TOP TURN-BY-TURN MANEUVER BANNER (Apple Maps / Google Maps Liquid Glass)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IosLiquidGlassSurface(
                    borderRadius: 26,
                    tintColor: _arrived
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFF0B3B2E),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    onTap: () => setState(
                      () => _showAllStepsSheet = !_showAllStepsSheet,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF30D158).withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF30D158).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Icon(
                            _arrived
                                ? Icons.check_circle_rounded
                                : _turnIcon(
                                    currentManeuver?.turnKind ??
                                        NavTurnKind.straight,
                                  ),
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _arrived
                                        ? 'Hedefe Ulaşıldı'
                                        : _formatTurnDistance(
                                            _distanceToNextTurnMeters,
                                          ),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_rerouting) ...[
                                    const SizedBox(width: 10),
                                    const CupertinoActivityIndicator(
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _arrived
                                    ? widget.destinationTitle
                                    : (currentManeuver?.instructionTr ??
                                        widget.destinationTitle),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFE5F9EC),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _showAllStepsSheet
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.list_bullet,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  // "Sonra:" Secondary Pill (just like Google Maps!)
                  if (nextManeuver != null && !_arrived && !_showAllStepsSheet)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, left: 10),
                        child: IosLiquidGlassSurface(
                          borderRadius: 16,
                          tintColor: const Color(0xFF08271E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Sonra: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                _turnIcon(nextManeuver.turnKind),
                                size: 16,
                                color: const Color(0xFF30D158),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  nextManeuver.instructionTr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Collapsible Full Turn List Drawer
                  if (_showAllStepsSheet && maneuvers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: IosLiquidGlassSurface(
                          borderRadius: 22,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: maneuvers.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            itemBuilder: (ctx, idx) {
                              final step = maneuvers[idx];
                              final active = idx == _currentStepIndex;
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  _turnIcon(step.turnKind),
                                  color: active
                                      ? const Color(0xFF30D158)
                                      : Colors.white70,
                                ),
                                title: Text(
                                  step.instructionTr,
                                  style: TextStyle(
                                    fontWeight: active
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: active
                                        ? const Color(0xFF30D158)
                                        : Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Text(
                                  _formatTurnDistance(step.distanceMeters),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. RIGHT-SIDE FLOATING iOS LIQUID-GLASS CONTROLS
          Positioned(
            right: 14,
            bottom: 136,
            child: Column(
              children: [
                IosGlassIconButton(
                  icon: _headingUpMode
                      ? CupertinoIcons.location_north_line_fill
                      : CupertinoIcons.compass,
                  activeColor: _headingUpMode ? const Color(0xFF0A84FF) : null,
                  tooltip: 'Sürüş Yönü Yukarı / Kuzey Yukarı',
                  onTap: () {
                    setState(() {
                      _headingUpMode = !_headingUpMode;
                      _followCamera = true;
                    });
                    _syncCameraToCar();
                  },
                ),
                const SizedBox(height: 10),
                IosGlassIconButton(
                  icon: isEv
                      ? CupertinoIcons.bolt_fill
                      : Icons.local_gas_station_rounded,
                  activeColor: _showPoisOnMap ? brand.primaryColor : null,
                  tooltip: 'Yol Üstü Şarj / Benzin İstasyonları',
                  onTap: () =>
                      setState(() => _showPoisOnMap = !_showPoisOnMap),
                ),
                const SizedBox(height: 10),
                IosGlassIconButton(
                  icon: darkTiles
                      ? CupertinoIcons.sun_max_fill
                      : CupertinoIcons.moon_fill,
                  tooltip: 'Gece / Gündüz Haritası',
                  onTap: appState.toggleMapTileStyle,
                ),
                const SizedBox(height: 10),
                IosGlassIconButton(
                  icon: _simulating
                      ? CupertinoIcons.pause_fill
                      : CupertinoIcons.play_arrow_solid,
                  activeColor:
                      _simulating ? const Color(0xFFFF9F0A) : null,
                  tooltip: _simulating
                      ? 'Simülasyonu Durdur'
                      : 'Canlı Sürüş Simülasyonu Başlat',
                  onTap: _toggleSimulation,
                ),
              ],
            ),
          ),

          // 4. LEFT-SIDE SPEEDOMETER + "RECENTER" PILL WHEN USER PANNED MAP
          Positioned(
            left: 14,
            bottom: 136,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_followCamera) ...[
                  IosLiquidGlassSurface(
                    borderRadius: 999,
                    tintColor: const Color(0xFF0A84FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    onTap: () {
                      setState(() => _followCamera = true);
                      _syncCameraToCar();
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.location_fill,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Merkezle',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // iPhone Apple Maps Speedometer Disc
                IosLiquidGlassSurface(
                  borderRadius: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_speedKmh.round()}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'km/s',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. BOTTOM APPLE MAPS / GOOGLE MAPS ETA & EXIT BAR
          Positioned(
            left: 14,
            right: 14,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 12),
              child: IosLiquidGlassSurface(
                borderRadius: 28,
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _arrived ? 'Varıldı' : '$_remainingMinutes dk',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF30D158),
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${_remainingDistanceKm.toStringAsFixed(1)} km · ${_formatArrivalTime(_remainingMinutes)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _simulating
                                ? '▶️ Canlı Demo Sürüş Aktif · ${widget.destinationTitle}'
                                : '📍 Hedef: ${widget.destinationTitle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Bitir',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMidRoutePoiSheet(LivePoiItem poi) {
    showIosGlassBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '${poi.distanceKm.toStringAsFixed(1)} km · ${poi.subtitle}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (poi.address != null) ...[
              const SizedBox(height: 4),
              Text(
                '📍 ${poi.address}',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (poi.phone != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          EmergencyService.dialPhoneNumber(poi.phone!),
                      icon: const Icon(CupertinoIcons.phone_fill, size: 16),
                      label: const Text('Ara'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ok = await widget.appState.setLiveDestination(
                        LivePlaceSearchResult(
                          displayName: poi.name,
                          shortName: poi.name,
                          point: poi.point,
                        ),
                      );
                      if (!mounted || !ok || widget.appState.liveRoute == null) {
                        return;
                      }
                      setState(() {
                        _route = widget.appState.liveRoute!;
                        _currentStepIndex =
                            _route.maneuvers.length > 1 ? 1 : 0;
                      });
                      _recomputeProgress();
                    },
                    icon: const Icon(CupertinoIcons.location_fill, size: 16),
                    label: const Text('Bu İstasyona Yönlendir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
