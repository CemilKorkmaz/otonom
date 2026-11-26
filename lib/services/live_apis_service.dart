import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/live_api_models.dart';

class LiveApisService {
  static const Map<String, String> _headers = {
    'User-Agent': 'OtonomSuperApp/1.3.0 (https://github.com/CemilKorkmaz/otonom)',
    'Accept': 'application/json',
  };

  static const List<String> _overpassMirrors = [
    'https://overpass.private.coffee/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  final http.Client _client;
  final Map<String, ApiEndpointStatus> statuses = {};

  LiveApisService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() {
    _client.close();
  }

  void _recordStatus({
    required String id,
    required String name,
    required String provider,
    required bool online,
    required int latencyMs,
    required String summary,
  }) {
    statuses[id] = ApiEndpointStatus(
      id: id,
      name: name,
      provider: provider,
      online: online,
      latencyMs: latencyMs,
      summary: summary,
      updatedAt: DateTime.now(),
    );
  }

  static double haversineKm(LatLng a, LatLng b) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }

  /// Calculates initial compass bearing (0..360°) from point A to point B
  static double bearingDegrees(LatLng from, LatLng to) {
    final lat1 = _degToRad(from.latitude);
    final lat2 = _degToRad(to.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * (180.0 / math.pi);
    return (brng + 360.0) % 360.0;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Real-time GPS stream for Fullscreen Turn-by-Turn Navigation
  Future<Stream<Position>?> openLiveNavigationStream() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.always &&
          perm != LocationPermission.whileInUse) {
        return null;
      }
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3,
        ),
      );
    } on Object {
      return null;
    }
  }

  /// 1. Real Device GPS + GeoJS Public IP Geolocation Fallback
  Future<({LatLng point, String source})> resolveCurrentLocation() async {
    final sw = Stopwatch()..start();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 7),
            ),
          );
          sw.stop();
          final pt = LatLng(pos.latitude, pos.longitude);
          _recordStatus(
            id: 'gps',
            name: 'Cihaz GPS Konumu',
            provider: 'Android/iOS GNSS',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary:
                '${pt.latitude.toStringAsFixed(4)}, ${pt.longitude.toStringAsFixed(4)}',
          );
          return (point: pt, source: 'Canlı GPS');
        }
      }
    } on Object {
      // Fall through to GeoJS IP location when GPS permission/hardware unavailable
    }

    try {
      final res = await _client
          .get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'), headers: _headers)
          .timeout(const Duration(seconds: 6));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final lat = double.tryParse(data['latitude']?.toString() ?? '');
        final lon = double.tryParse(data['longitude']?.toString() ?? '');
        final city = data['city']?.toString() ?? 'İstanbul';
        if (lat != null && lon != null) {
          final pt = LatLng(lat, lon);
          _recordStatus(
            id: 'gps',
            name: 'IP Konum Servisi (GeoJS)',
            provider: 'get.geojs.io',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: '$city (${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)})',
          );
          return (point: pt, source: 'Canlı Konum ($city)');
        }
      }
    } on Object {
      // Recorded below
    }

    sw.stop();
    const istanbul = LatLng(40.9903, 29.0292);
    _recordStatus(
      id: 'gps',
      name: 'Konum Servisi',
      provider: 'Varsayılan Merkez',
      online: false,
      latencyMs: sw.elapsedMilliseconds,
      summary: 'Konum izni bekleniyor (Varsayılan: İstanbul)',
    );
    return (point: istanbul, source: 'İstanbul Merkez');
  }

  /// 2A. Nominatim Reverse Geocoding
  Future<String> reverseGeocodeAddress(LatLng point) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
      '&lat=${point.latitude}&lon=${point.longitude}&accept-language=tr',
    );
    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 7));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final display = (data['display_name']?.toString() ?? '').trim();
        if (display.isNotEmpty) {
          _recordStatus(
            id: 'nominatim',
            name: 'Açık Adres & Arama (Nominatim)',
            provider: 'nominatim.openstreetmap.org',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: display.length > 48 ? '${display.substring(0, 48)}...' : display,
          );
          return display;
        }
      }
      _recordStatus(
        id: 'nominatim',
        name: 'Açık Adres & Arama (Nominatim)',
        provider: 'nominatim.openstreetmap.org',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'HTTP ${res.statusCode} yanıtı alındı',
      );
    } on Object {
      sw.stop();
      _recordStatus(
        id: 'nominatim',
        name: 'Açık Adres & Arama (Nominatim)',
        provider: 'nominatim.openstreetmap.org',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'Ağ zaman aşımı — koordinat gösteriliyor',
      );
    }
    return '${point.latitude.toStringAsFixed(5)}° K, ${point.longitude.toStringAsFixed(5)}° D';
  }

  /// 2B. Nominatim + Photon Combined Place Search (fast autocomplete & search!)
  Future<List<LivePlaceSearchResult>> searchPlaces(String query, {LatLng? biasPoint}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=jsonv2'
      '&q=${Uri.encodeComponent(q)}&limit=6&accept-language=tr',
    );
    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      sw.stop();
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final results = <LivePlaceSearchResult>[];
        for (final raw in list) {
          final map = raw as Map<String, dynamic>;
          final lat = double.tryParse(map['lat']?.toString() ?? '');
          final lon = double.tryParse(map['lon']?.toString() ?? '');
          final display = map['display_name']?.toString() ?? '';
          if (lat != null && lon != null && display.isNotEmpty) {
            final shortName = display.split(',').take(2).join(',').trim();
            results.add(
              LivePlaceSearchResult(
                displayName: display,
                shortName: shortName,
                point: LatLng(lat, lon),
              ),
            );
          }
        }
        if (results.isNotEmpty) return results;
      }
    } on Object {
      sw.stop();
    }

    // Fallback to Photon Komoot Search if Nominatim was throttled
    try {
      final bias = biasPoint != null
          ? '&lat=${biasPoint.latitude}&lon=${biasPoint.longitude}'
          : '';
      final pUri = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeQueryComponent(q)}&limit=6$bias',
      );
      final pRes =
          await _client.get(pUri, headers: _headers).timeout(const Duration(seconds: 6));
      if (pRes.statusCode == 200) {
        final data = jsonDecode(pRes.body) as Map<String, dynamic>;
        final features = (data['features'] as List<dynamic>?) ?? [];
        final out = <LivePlaceSearchResult>[];
        for (final f in features) {
          final fm = f as Map<String, dynamic>;
          final coords =
              ((fm['geometry'] as Map<String, dynamic>?)?['coordinates'] as List<dynamic>?) ??
                  [];
          if (coords.length < 2) continue;
          final props = (fm['properties'] as Map<String, dynamic>?) ?? {};
          final name = props['name']?.toString() ?? q;
          final city = props['city'] ?? props['state'] ?? props['country'] ?? '';
          final full = city.toString().isNotEmpty ? '$name, $city' : name;
          out.add(
            LivePlaceSearchResult(
              displayName: full,
              shortName: name,
              point: LatLng(
                (coords[1] as num).toDouble(),
                (coords[0] as num).toDouble(),
              ),
            ),
          );
        }
        return out;
      }
    } on Object {
      // Return empty cleanly
    }
    return [];
  }

  /// 3. Project OSRM Live Road Route Calculation with Full Turn-by-Turn Maneuvers!
  Future<LiveOsrmRoute?> fetchDrivingRoute(LatLng origin, LatLng destination) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );
    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 9));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final first = routes.first as Map<String, dynamic>;
          final distMeters = (first['distance'] as num?)?.toDouble() ?? 0.0;
          final durSeconds = (first['duration'] as num?)?.toDouble() ?? 0.0;
          final geom = first['geometry'] as Map<String, dynamic>?;
          final coords = (geom?['coordinates'] as List<dynamic>?) ?? [];
          final pts = <LatLng>[];
          for (final c in coords) {
            if (c is List && c.length >= 2) {
              pts.add(LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()));
            }
          }

          final stepsOut = <String>[];
          final maneuversOut = <LiveNavManeuverStep>[];
          final legs = (first['legs'] as List<dynamic>?) ?? [];
          if (legs.isNotEmpty) {
            final steps =
                ((legs.first as Map<String, dynamic>)['steps'] as List<dynamic>?) ??
                    [];
            for (final rawStep in steps) {
              final sm = rawStep as Map<String, dynamic>;
              final rawName = (sm['name']?.toString() ?? '').trim();
              final rawRef = (sm['ref']?.toString() ?? '').trim();
              final roadName = rawName.isNotEmpty
                  ? (rawRef.isNotEmpty && !rawName.contains(rawRef)
                      ? '$rawName ($rawRef)'
                      : rawName)
                  : (rawRef.isNotEmpty ? rawRef : 'Yol');
              final stepDistM = (sm['distance'] as num?)?.toDouble() ?? 0.0;
              final stepDurS = (sm['duration'] as num?)?.toDouble() ?? 0.0;

              final man = (sm['maneuver'] as Map<String, dynamic>?) ?? {};
              final mType = man['type']?.toString() ?? 'continue';
              final mMod = man['modifier']?.toString() ?? 'straight';
              final mExit = (man['exit'] as num?)?.toInt();
              final mLoc = (man['location'] as List<dynamic>?) ?? [];
              final stepPoint = mLoc.length >= 2
                  ? LatLng((mLoc[1] as num).toDouble(), (mLoc[0] as num).toDouble())
                  : (pts.isNotEmpty ? pts.first : origin);

              final parsed = _translateOsrmManeuver(
                type: mType,
                modifier: mMod,
                roadName: roadName,
                exitNumber: mExit,
              );

              maneuversOut.add(
                LiveNavManeuverStep(
                  location: stepPoint,
                  roadName: roadName,
                  instructionTr: parsed.instructionTr,
                  turnKind: parsed.turnKind,
                  distanceMeters: stepDistM,
                  durationSeconds: stepDurS,
                ),
              );

              if (stepDistM > 30 || mType == 'arrive') {
                stepsOut.add(parsed.instructionTr);
              }
            }
          }

          final km = distMeters / 1000.0;
          final mins = math.max(1, (durSeconds / 60.0).round());
          _recordStatus(
            id: 'osrm',
            name: 'Canlı Yol Rotası (OSRM)',
            provider: 'router.project-osrm.org',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary:
                '${km.toStringAsFixed(1)} km · $mins dk · ${maneuversOut.length} dönüş adımı',
          );
          return LiveOsrmRoute(
            polyline: pts,
            distanceKm: km,
            durationMinutes: mins,
            stepInstructions: stepsOut,
            maneuvers: maneuversOut,
          );
        }
      }
      _recordStatus(
        id: 'osrm',
        name: 'Canlı Yol Rotası (OSRM)',
        provider: 'router.project-osrm.org',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'Rota yanıtı alınamadı (HTTP ${res.statusCode})',
      );
    } on Object {
      sw.stop();
      _recordStatus(
        id: 'osrm',
        name: 'Canlı Yol Rotası (OSRM)',
        provider: 'router.project-osrm.org',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'Rota sunucusuna ulaşılamadı',
      );
    }
    return null;
  }

  ({String instructionTr, NavTurnKind turnKind}) _translateOsrmManeuver({
    required String type,
    required String modifier,
    required String roadName,
    int? exitNumber,
  }) {
    final target = roadName != 'Yol' ? '$roadName yönüne ' : '';
    if (type == 'arrive') {
      return (instructionTr: 'Hedefinize ulaştınız', turnKind: NavTurnKind.arrive);
    }
    if (type == 'depart') {
      return (
        instructionTr: '${roadName != "Yol" ? roadName : "Rota"} üzerinden ilerleyin',
        turnKind: NavTurnKind.depart,
      );
    }
    if (type == 'roundabout' || type == 'rotary') {
      final ex = exitNumber != null ? '$exitNumber. çıkıştan ' : '';
      return (
        instructionTr: 'Döner kavşaktan $ex$targetçıkın',
        turnKind: NavTurnKind.roundabout,
      );
    }
    if (type == 'merge') {
      return (
        instructionTr: '${target}anayola katılın',
        turnKind: NavTurnKind.merge,
      );
    }
    if (type == 'on ramp' || type == 'off ramp') {
      return (
        instructionTr: '${target}bağlantı yolunu kullanın',
        turnKind: NavTurnKind.ramp,
      );
    }

    switch (modifier) {
      case 'left':
        return (instructionTr: '${target}sola dönün', turnKind: NavTurnKind.left);
      case 'slight left':
        return (
          instructionTr: '${target}hafif sola yönelin',
          turnKind: NavTurnKind.slightLeft,
        );
      case 'sharp left':
        return (
          instructionTr: '${target}keskin sola dönün',
          turnKind: NavTurnKind.sharpLeft,
        );
      case 'right':
        return (instructionTr: '${target}sağa dönün', turnKind: NavTurnKind.right);
      case 'slight right':
        return (
          instructionTr: '${target}hafif sağa yönelin',
          turnKind: NavTurnKind.slightRight,
        );
      case 'sharp right':
        return (
          instructionTr: '${target}keskin sağa dönün',
          turnKind: NavTurnKind.sharpRight,
        );
      case 'uturn':
        return (
          instructionTr: 'U dönüşü yapın',
          turnKind: NavTurnKind.uTurn,
        );
      default:
        return (
          instructionTr: '${roadName != "Yol" ? "$roadName boyunca " : ""}düz devam edin',
          turnKind: NavTurnKind.straight,
        );
    }
  }

  /// 4. ZERO-RATE-LIMIT UNIFIED AUTOMOTIVE POI ENGINE (Overpass + Photon Komoot)
  Future<({
    List<LivePoiItem> evStations,
    List<LivePoiItem> fuelStations,
    List<LivePoiItem> towRepairs,
    List<LivePoiItem> carRentals,
  })> fetchAllAutomotivePoisUnified({
    required LatLng center,
    List<LatLng> routePolyline = const [],
  }) async {
    final sw = Stopwatch()..start();
    final evList = <LivePoiItem>[];
    final fuelList = <LivePoiItem>[];
    final towList = <LivePoiItem>[];
    final rentList = <LivePoiItem>[];

    String midpointClause = '';
    if (routePolyline.length >= 8) {
      final mid = routePolyline[routePolyline.length ~/ 2];
      midpointClause = '''
  node["amenity"="charging_station"](around:10000,${mid.latitude.toStringAsFixed(4)},${mid.longitude.toStringAsFixed(4)});
  node["amenity"="fuel"](around:8000,${mid.latitude.toStringAsFixed(4)},${mid.longitude.toStringAsFixed(4)});
''';
    }

    final latS = center.latitude.toStringAsFixed(4);
    final lonS = center.longitude.toStringAsFixed(4);
    final batchedQl = '''
[out:json][timeout:14];
(
  node["amenity"="charging_station"](around:14000,$latS,$lonS);
  node["amenity"="fuel"](around:10000,$latS,$lonS);
  node["amenity"="car_rental"](around:15000,$latS,$lonS);
  node["shop"~"^(car_repair|tyres)\$"](around:10000,$latS,$lonS);
$midpointClause
);
out body 120;
''';

    bool overpassSucceeded = false;
    String winningMirror = 'photon.komoot.io';

    for (final mirror in _overpassMirrors) {
      try {
        final res = await _client
            .post(
              Uri.parse(mirror),
              headers: {
                ..._headers,
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              },
              body: 'data=${Uri.encodeQueryComponent(batchedQl)}',
            )
            .timeout(const Duration(seconds: 9));

        if (res.statusCode == 200) {
          final payload = jsonDecode(res.body) as Map<String, dynamic>;
          final elements = (payload['elements'] as List<dynamic>?) ?? [];
          for (final raw in elements) {
            final el = raw as Map<String, dynamic>;
            final lat = (el['lat'] as num?)?.toDouble();
            final lon = (el['lon'] as num?)?.toDouble();
            if (lat == null || lon == null) continue;
            final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
            final amenity = tags['amenity']?.toString() ?? '';
            final shop = tags['shop']?.toString() ?? '';

            String? cat;
            if (amenity == 'charging_station') {
              cat = 'ev';
            } else if (amenity == 'fuel') {
              cat = 'fuel';
            } else if (amenity == 'car_rental') {
              cat = 'car_rental';
            } else if (shop == 'car_repair' || shop == 'tyres') {
              cat = 'tow_repair';
            }
            if (cat == null) continue;

            final item = _mapOsmTagsToPoi(
              id: '${el['type']}_${el['id']}',
              lat: lat,
              lon: lon,
              center: center,
              category: cat,
              tags: tags,
            );

            if (cat == 'ev') evList.add(item);
            if (cat == 'fuel') fuelList.add(item);
            if (cat == 'tow_repair') towList.add(item);
            if (cat == 'car_rental') rentList.add(item);
          }
          overpassSucceeded = true;
          winningMirror = Uri.parse(mirror).host;
          break;
        }
      } on Object {
        // Try next mirror
      }
    }

    final supplements = <Future<void>>[];
    if (evList.length < 3) {
      supplements.add(
        _supplementFromPhoton(center, 'ev', ['Şarj', 'ZES', 'Eşarj', 'Trugo'], evList),
      );
    }
    if (fuelList.length < 3) {
      supplements.add(
        _supplementFromPhoton(center, 'fuel', ['Opet', 'Shell', 'Petrol Ofisi'], fuelList),
      );
    }
    if (towList.length < 3) {
      supplements.add(
        _supplementFromPhoton(
          center,
          'tow_repair',
          ['Oto Kurtarma', 'Oto Çekici', 'Oto Servis', 'Oto Tamir'],
          towList,
        ),
      );
    }
    if (rentList.length < 3) {
      supplements.add(
        _supplementFromPhoton(
          center,
          'car_rental',
          ['Rent a Car', 'Araç Kiralama', 'Avis', 'Garenta'],
          rentList,
        ),
      );
    }
    if (supplements.isNotEmpty) {
      await Future.wait(supplements);
    }

    evList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    fuelList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    towList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    rentList.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    sw.stop();
    final totalFound =
        evList.length + fuelList.length + towList.length + rentList.length;
    _recordStatus(
      id: 'osm_pois',
      name: 'Şarj, Benzin, Çekici & Kiralama Noktaları',
      provider: overpassSucceeded ? winningMirror : 'photon.komoot.io (OSM)',
      online: totalFound > 0,
      latencyMs: sw.elapsedMilliseconds,
      summary:
          'EV: ${evList.length} · Yakıt: ${fuelList.length} · Servis: ${towList.length} · Kiralama: ${rentList.length}',
    );

    return (
      evStations: evList.take(25).toList(),
      fuelStations: fuelList.take(25).toList(),
      towRepairs: towList.take(25).toList(),
      carRentals: rentList.take(25).toList(),
    );
  }

  Future<void> _supplementFromPhoton(
    LatLng center,
    String category,
    List<String> keywords,
    List<LivePoiItem> target,
  ) async {
    final existingNames = target.map((e) => e.name.toLowerCase()).toSet();
    for (final kw in keywords) {
      if (target.length >= 12) break;
      try {
        final uri = Uri.parse(
          'https://photon.komoot.io/api/?q=${Uri.encodeQueryComponent(kw)}'
          '&lat=${center.latitude}&lon=${center.longitude}&limit=8',
        );
        final res =
            await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final features = (data['features'] as List<dynamic>?) ?? [];
          for (final f in features) {
            final fm = f as Map<String, dynamic>;
            final geom = fm['geometry'] as Map<String, dynamic>?;
            final coords = (geom?['coordinates'] as List<dynamic>?) ?? [];
            if (coords.length < 2) continue;
            final lon = (coords[0] as num).toDouble();
            final lat = (coords[1] as num).toDouble();
            final pt = LatLng(lat, lon);
            final distKm = haversineKm(center, pt);
            if (distKm > 35.0) continue;

            final props = (fm['properties'] as Map<String, dynamic>?) ?? {};
            final name = (props['name']?.toString() ?? kw).trim();
            if (existingNames.contains(name.toLowerCase())) continue;
            existingNames.add(name.toLowerCase());

            final address = [
              props['street'],
              props['district'] ?? props['suburb'],
              props['city'],
            ].where((x) => x != null && x.toString().trim().isNotEmpty).join(', ');

            target.add(
              LivePoiItem(
                id: 'photon_${props['osm_id'] ?? name.hashCode}',
                name: name,
                brandOrOperator: kw,
                category: category,
                point: pt,
                distanceKm: distKm,
                address: address.isNotEmpty ? address : null,
                subtitle: _defaultPoiLabel(category),
                tags: const ['Canlı Photon OSM'],
              ),
            );
          }
        }
      } on Object {
        // Continue with next keyword
      }
    }
  }

  LivePoiItem _mapOsmTagsToPoi({
    required String id,
    required double lat,
    required double lon,
    required LatLng center,
    required String category,
    required Map<String, dynamic> tags,
  }) {
    final rawName =
        (tags['name'] ?? tags['brand'] ?? tags['operator'] ?? _defaultPoiLabel(category))
            .toString()
            .trim();
    final brand = (tags['brand'] ?? tags['operator'] ?? rawName).toString().trim();
    final phone =
        (tags['phone'] ?? tags['contact:phone'] ?? tags['mobile'])?.toString().trim();
    final street = [
      tags['addr:street'],
      tags['addr:suburb'] ?? tags['addr:district'],
      tags['addr:city'],
    ].where((x) => x != null && x.toString().trim().isNotEmpty).join(', ');

    final pt = LatLng(lat, lon);
    final distKm = haversineKm(center, pt);

    return LivePoiItem(
      id: id,
      name: rawName,
      brandOrOperator: brand,
      category: category,
      point: pt,
      distanceKm: distKm,
      phone: (phone != null && phone.isNotEmpty) ? phone : null,
      address: street.isNotEmpty ? street : null,
      subtitle: _buildPoiSubtitle(category, tags, brand),
      tags: _buildPoiTags(tags),
    );
  }

  String _defaultPoiLabel(String category) {
    switch (category) {
      case 'ev':
        return '⚡ Elektrikli Şarj İstasyonu';
      case 'fuel':
        return '⛽ Akaryakıt İstasyonu';
      case 'tow_repair':
        return '🔧 Oto Kurtarma & Servis Noktası';
      case 'car_rental':
        return '🔑 Araç Kiralama Ofisi';
      default:
        return 'Otomotiv Noktası';
    }
  }

  String _buildPoiSubtitle(
    String category,
    Map<String, dynamic> tags,
    String brand,
  ) {
    if (category == 'ev') {
      final cap = tags['capacity'] ?? tags['socket:ccs'] ?? tags['socket:type2'] ?? '2+';
      final output = tags['socket:ccs:output'] ??
          tags['charging_station:output'] ??
          tags['maxpower'] ??
          'AC/DC Şarj';
      return '⚡ $brand · Güç: $output · $cap Soket';
    }
    if (category == 'fuel') {
      final fuels = <String>[];
      if (tags['fuel:octane_95'] == 'yes' || tags['fuel:gasoline'] == 'yes') {
        fuels.add('Kurşunsuz 95');
      }
      if (tags['fuel:diesel'] == 'yes') fuels.add('Motorin');
      if (tags['fuel:lpg'] == 'yes') fuels.add('LPG');
      final fText = fuels.isEmpty ? 'Benzin & Motorin' : fuels.join(' · ');
      return '⛽ $brand · $fText';
    }
    if (category == 'tow_repair') {
      return '🔧 $brand · Mekanik, Çekici & Yol Yardım';
    }
    final opening = tags['opening_hours'] ?? 'Aktif Şube';
    return '🔑 $brand · $opening';
  }

  List<String> _buildPoiTags(Map<String, dynamic> tags) {
    final res = <String>['Canlı OSM'];
    if (tags['opening_hours'] == '24/7') res.add('7/24 Açık');
    if (tags['socket:ccs'] != null) res.add('CCS2 DC');
    if (tags['socket:type2'] != null) res.add('Type 2 AC');
    if (tags['phone'] != null || tags['contact:phone'] != null) {
      res.add('Telefon Mevcut');
    }
    return res;
  }

  /// 5. Open-Meteo Live Road Weather & Grip Telemetry
  Future<LiveRoadWeather?> fetchRoadWeather(LatLng point) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${point.latitude.toStringAsFixed(4)}'
      '&longitude=${point.longitude.toStringAsFixed(4)}'
      '&current=temperature_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
    );
    try {
      final res =
          await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 7));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final cur = (data['current'] as Map<String, dynamic>?) ?? {};
        final temp = (cur['temperature_2m'] as num?)?.toDouble() ?? 18.0;
        final appTemp = (cur['apparent_temperature'] as num?)?.toDouble() ?? temp;
        final precip = (cur['precipitation'] as num?)?.toDouble() ?? 0.0;
        final wind = (cur['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
        final code = (cur['weather_code'] as num?)?.toInt() ?? 0;

        final condition = _weatherCodeTr(code);
        String advisory;
        if (temp <= 4.0) {
          advisory =
              '❄️ Asfalt sıcaklığı kritik (${temp.toStringAsFixed(1)}°C): Gizli buzlanma riski ve EV rejenerasyon düşüşü olabilir.';
        } else if (precip > 0.2 || code >= 51) {
          advisory =
              '🌧️ Islak zemin (${precip.toStringAsFixed(1)} mm): Takip mesafesini 2 katına çıkarın.';
        } else {
          advisory =
              '✅ İdeal sürüş zemini (${temp.toStringAsFixed(1)}°C · Rüzgâr ${wind.toStringAsFixed(0)} km/s).';
        }

        _recordStatus(
          id: 'open_meteo',
          name: 'Yol Hava & Zemin Telemetrisi',
          provider: 'api.open-meteo.com',
          online: true,
          latencyMs: sw.elapsedMilliseconds,
          summary: '${temp.toStringAsFixed(1)}°C · $condition',
        );

        return LiveRoadWeather(
          temperatureC: temp,
          apparentTempC: appTemp,
          windSpeedKmh: wind,
          precipitationMm: precip,
          weatherCode: code,
          conditionTr: condition,
          drivingAdvisoryTr: advisory,
        );
      }
      _recordStatus(
        id: 'open_meteo',
        name: 'Yol Hava & Zemin Telemetrisi',
        provider: 'api.open-meteo.com',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'HTTP ${res.statusCode}',
      );
    } on Object {
      sw.stop();
      _recordStatus(
        id: 'open_meteo',
        name: 'Yol Hava & Zemin Telemetrisi',
        provider: 'api.open-meteo.com',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'Hava durumu servisine ulaşılamadı',
      );
    }
    return null;
  }

  String _weatherCodeTr(int code) {
    if (code == 0) return 'Açık / Net Görüş';
    if (code <= 3) return 'Parçalı Bulutlu';
    if (code == 45 || code == 48) return 'Sisli';
    if (code >= 51 && code <= 67) return 'Yağmurlu';
    if (code >= 71 && code <= 77) return 'Kar Yağışlı';
    if (code >= 80 && code <= 82) return 'Sağanak Yağışlı';
    if (code >= 95) return 'Fırtınalı';
    return 'Normal Yol Koşulu';
  }

  /// 6A. NHTSA vPIC + EPA Combined Live Models for ANY Brand + Year
  Future<List<String>> fetchGlobalModelsForMakeYear({
    required String make,
    required String year,
  }) async {
    final sw = Stopwatch()..start();
    final modelsSet = <String>{};

    final nhtsaUri = Uri.parse(
      'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/'
      '${Uri.encodeComponent(make.trim())}/modelyear/${Uri.encodeComponent(year.trim())}?format=json',
    );
    final epaUri = Uri.parse(
      'https://www.fueleconomy.gov/ws/rest/vehicle/menu/model'
      '?year=${Uri.encodeQueryComponent(year.trim())}&make=${Uri.encodeQueryComponent(make.trim())}',
    );

    try {
      final results = await Future.wait([
        _client.get(nhtsaUri, headers: _headers).timeout(const Duration(seconds: 7)),
        _client.get(epaUri, headers: _headers).timeout(const Duration(seconds: 7)),
      ]);

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body) as Map<String, dynamic>;
        final list = (data['Results'] as List<dynamic>?) ?? [];
        for (final item in list) {
          final name = (item as Map<String, dynamic>)['Model_Name']?.toString() ?? '';
          if (name.trim().isNotEmpty) modelsSet.add(name.trim());
        }
      }
      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body);
        for (final item in _extractMenuItems(data)) {
          final name = item['value']?.toString() ?? item['text']?.toString() ?? '';
          if (name.trim().isNotEmpty) modelsSet.add(name.trim());
        }
      }
      sw.stop();
      _recordStatus(
        id: 'nhtsa_vpic',
        name: 'Global Araç Katalog API (NHTSA+EPA)',
        provider: 'vpic.nhtsa.dot.gov',
        online: true,
        latencyMs: sw.elapsedMilliseconds,
        summary: '$year $make için ${modelsSet.length} canlı model bulundu',
      );
    } on Object {
      sw.stop();
      _recordStatus(
        id: 'nhtsa_vpic',
        name: 'Global Araç Katalog API (NHTSA+EPA)',
        provider: 'vpic.nhtsa.dot.gov',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'Çevrimdışı katalog önerileri kullanılıyor',
      );
    }

    final sorted = modelsSet.toList()..sort();
    return sorted;
  }

  /// 6B. NHTSA Live Safety Recalls & Owner Complaints
  Future<({List<LiveRecallItem> recalls, List<LiveComplaintItem> complaints})>
      fetchRecallsAndComplaints({
    required String make,
    required String model,
    required String year,
  }) async {
    final sw = Stopwatch()..start();
    final recallsOut = <LiveRecallItem>[];
    final complaintsOut = <LiveComplaintItem>[];
    final cleanModel = model.split(' ').first.trim();

    final recallUri = Uri.parse(
      'https://api.nhtsa.gov/recalls/recallsByVehicle'
      '?make=${Uri.encodeQueryComponent(make)}'
      '&model=${Uri.encodeQueryComponent(cleanModel)}'
      '&modelYear=${Uri.encodeQueryComponent(year)}',
    );
    final complaintUri = Uri.parse(
      'https://api.nhtsa.gov/complaints/complaintsByVehicle'
      '?make=${Uri.encodeQueryComponent(make)}'
      '&model=${Uri.encodeQueryComponent(cleanModel)}'
      '&modelYear=${Uri.encodeQueryComponent(year)}',
    );

    try {
      final responses = await Future.wait([
        _client.get(recallUri, headers: _headers).timeout(const Duration(seconds: 8)),
        _client.get(complaintUri, headers: _headers).timeout(const Duration(seconds: 8)),
      ]);
      sw.stop();

      if (responses[0].statusCode == 200) {
        final rData = jsonDecode(responses[0].body) as Map<String, dynamic>;
        final rList = (rData['results'] as List<dynamic>?) ?? [];
        for (final item in rList.take(10)) {
          final m = item as Map<String, dynamic>;
          recallsOut.add(
            LiveRecallItem(
              campaignNumber: m['NHTSACampaignNumber']?.toString() ?? '-',
              component: m['Component']?.toString() ?? 'Donanım',
              summary: m['Summary']?.toString() ?? '',
              consequence: m['Consequence']?.toString() ?? '',
              remedy: m['Remedy']?.toString() ?? '',
              reportDate: m['ReportReceivedDate']?.toString() ?? '',
            ),
          );
        }
      }

      if (responses[1].statusCode == 200) {
        final cData = jsonDecode(responses[1].body) as Map<String, dynamic>;
        final cList = (cData['results'] as List<dynamic>?) ?? [];
        for (final item in cList.take(12)) {
          final m = item as Map<String, dynamic>;
          complaintsOut.add(
            LiveComplaintItem(
              odiNumber: m['odiNumber']?.toString() ?? '-',
              components: m['components']?.toString() ?? 'Sistem',
              summary: m['summary']?.toString() ?? '',
              crash: m['crash'] == true,
              fire: m['fire'] == true,
              dateIncident: m['dateOfIncident']?.toString() ?? '',
            ),
          );
        }
      }

      _recordStatus(
        id: 'nhtsa_safety',
        name: 'Geri Çağırma & Kronik Şikayet API',
        provider: 'api.nhtsa.gov',
        online: true,
        latencyMs: sw.elapsedMilliseconds,
        summary:
            '${recallsOut.length} recall · ${complaintsOut.length} sürücü şikayeti',
      );
    } on Object {
      sw.stop();
      _recordStatus(
        id: 'nhtsa_safety',
        name: 'Geri Çağırma & Kronik Şikayet API',
        provider: 'api.nhtsa.gov',
        online: false,
        latencyMs: sw.elapsedMilliseconds,
        summary: 'NHTSA güvenlik sunucusuna ulaşılamadı',
      );
    }

    return (recalls: recallsOut, complaints: complaintsOut);
  }

  /// 7. US EPA FuelEconomy.gov Live Technical Specs
  Future<List<LiveEpaVehicleSpec>> fetchEpaVehicleSpecs({
    required String year,
    required String make,
    required String model,
  }) async {
    final sw = Stopwatch()..start();
    final cleanModel = model.split(' ').first.trim();

    for (final candidateModel in {model.trim(), cleanModel}) {
      if (candidateModel.isEmpty) continue;
      final optionsUri = Uri.parse(
        'https://www.fueleconomy.gov/ws/rest/vehicle/menu/options'
        '?year=${Uri.encodeQueryComponent(year)}'
        '&make=${Uri.encodeQueryComponent(make)}'
        '&model=${Uri.encodeQueryComponent(candidateModel)}',
      );

      try {
        final optRes = await _client
            .get(optionsUri, headers: _headers)
            .timeout(const Duration(seconds: 7));
        if (optRes.statusCode != 200) continue;
        final optJson = jsonDecode(optRes.body);
        final rawItems = _extractMenuItems(optJson);
        if (rawItems.isEmpty) continue;

        final specs = <LiveEpaVehicleSpec>[];
        for (final item in rawItems.take(5)) {
          final vehicleId = item['value']?.toString() ?? '';
          final trimText = item['text']?.toString() ?? '';
          if (vehicleId.isEmpty) continue;

          final detailRes = await _client
              .get(
                Uri.parse('https://www.fueleconomy.gov/ws/rest/vehicle/$vehicleId'),
                headers: _headers,
              )
              .timeout(const Duration(seconds: 7));
          if (detailRes.statusCode == 200) {
            final v = jsonDecode(detailRes.body) as Map<String, dynamic>;
            final combMpg = double.tryParse(v['comb08']?.toString() ?? '') ?? 0;
            final cityMpg = double.tryParse(v['city08']?.toString() ?? '') ?? 0;
            final hwyMpg = double.tryParse(v['highway08']?.toString() ?? '') ?? 0;
            final combKwh = double.tryParse(v['combE']?.toString() ?? '') ?? 0;
            final fuelType = v['fuelType']?.toString() ?? 'Benzin';
            final isEv = fuelType.toLowerCase().contains('electricity');

            String combLabel = '-';
            String cityLabel = '-';
            String hwyLabel = '-';
            if (isEv && combKwh > 0) {
              combLabel = '${(combKwh * 0.621371).toStringAsFixed(1)} kWh/100km';
              cityLabel = combLabel;
              hwyLabel = combLabel;
            } else if (combMpg > 0) {
              combLabel = '${(235.215 / combMpg).toStringAsFixed(1)} L/100km';
              cityLabel = cityMpg > 0
                  ? '${(235.215 / cityMpg).toStringAsFixed(1)} L/100km'
                  : '-';
              hwyLabel = hwyMpg > 0
                  ? '${(235.215 / hwyMpg).toStringAsFixed(1)} L/100km'
                  : '-';
            }

            final co2PerMile = double.tryParse(v['co2TailpipeGpm']?.toString() ?? '');
            final co2Km = (co2PerMile != null && co2PerMile > 0)
                ? '${(co2PerMile * 0.621371).round()} g/km'
                : '0 g/km';

            specs.add(
              LiveEpaVehicleSpec(
                id: vehicleId,
                make: v['make']?.toString() ?? make,
                model: v['model']?.toString() ?? candidateModel,
                year: v['year']?.toString() ?? year,
                trimDescription: trimText,
                cylinders:
                    v['cylinders']?.toString() ?? (isEv ? 'Elektrik Motoru' : '-'),
                displacementL: v['displ'] != null
                    ? '${v['displ']} Litre'
                    : (isEv ? 'Yüksek Voltaj Batarya' : '-'),
                drive: v['drive']?.toString() ?? '-',
                transmission: v['trany']?.toString() ?? '-',
                fuelType: fuelType,
                combinedConsumption: combLabel,
                cityConsumption: cityLabel,
                highwayConsumption: hwyLabel,
                co2GramsPerKm: co2Km,
              ),
            );
          }
        }
        if (specs.isNotEmpty) {
          sw.stop();
          _recordStatus(
            id: 'epa_fueleconomy',
            name: 'Fabrika Tüketim & Motor API (EPA)',
            provider: 'fueleconomy.gov',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: '${specs.length} motor/şanzıman paketi çekildi',
          );
          return specs;
        }
      } on Object {
        // Try next candidate model token
      }
    }

    sw.stop();
    return [];
  }

  /// 8. Wikipedia TR + EN Live Vehicle Photo & History Dossier API
  Future<LiveWikipediaVehicleSummary?> fetchVehicleWikipediaSummary({
    required String make,
    required String model,
  }) async {
    final sw = Stopwatch()..start();
    final searchQuery = '$make $model'.trim();

    for (final lang in const ['tr', 'en']) {
      try {
        final searchUri = Uri.parse(
          'https://$lang.wikipedia.org/w/api.php?action=query&list=search'
          '&srsearch=${Uri.encodeQueryComponent(searchQuery)}&format=json&srlimit=1',
        );
        final sRes = await _client
            .get(searchUri, headers: _headers)
            .timeout(const Duration(seconds: 6));
        if (sRes.statusCode != 200) continue;
        final sJson = jsonDecode(sRes.body) as Map<String, dynamic>;
        final hits =
            ((sJson['query'] as Map<String, dynamic>?)?['search'] as List<dynamic>?) ??
                [];
        if (hits.isEmpty) continue;
        final pageTitle = (hits.first as Map<String, dynamic>)['title']?.toString() ?? '';
        if (pageTitle.isEmpty) continue;

        final summaryUri = Uri.parse(
          'https://$lang.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(pageTitle.replaceAll(' ', '_'))}',
        );
        final sumRes = await _client
            .get(summaryUri, headers: _headers)
            .timeout(const Duration(seconds: 6));
        if (sumRes.statusCode == 200) {
          final data = jsonDecode(sumRes.body) as Map<String, dynamic>;
          final extract = (data['extract']?.toString() ?? '').trim();
          if (extract.isEmpty) continue;
          final thumb =
              (data['originalimage'] as Map<String, dynamic>?)?['source']?.toString() ??
                  (data['thumbnail'] as Map<String, dynamic>?)?['source']?.toString();
          final contentUrls = data['content_urls'] as Map<String, dynamic>?;
          final desktopUrl =
              (contentUrls?['desktop'] as Map<String, dynamic>?)?['page']?.toString();

          sw.stop();
          _recordStatus(
            id: 'wikipedia_auto',
            name: 'Araç Ansiklopedi & Görsel API',
            provider: '$lang.wikipedia.org',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: pageTitle,
          );
          return LiveWikipediaVehicleSummary(
            title: pageTitle,
            extract: extract,
            imageUrl: thumb,
            pageUrl: desktopUrl,
          );
        }
      } on Object {
        // Fallback to next language
      }
    }
    sw.stop();
    return null;
  }

  List<Map<String, dynamic>> _extractMenuItems(dynamic jsonPayload) {
    if (jsonPayload is! Map<String, dynamic>) return [];
    final raw = jsonPayload['menuItem'];
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      return [raw];
    }
    return [];
  }
}
