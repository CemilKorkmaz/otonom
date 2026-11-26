import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/live_api_models.dart';

/// Connects Otonom to 7 real, keyless public APIs (from public-apis & OpenStreetMap):
/// 1. Device GPS (Geolocator) + GeoJS IP Geolocation fallback (https://get.geojs.io)
/// 2. Nominatim OpenStreetMap Geocoding & Reverse Geocoding (https://nominatim.openstreetmap.org)
/// 3. Project OSRM Live Road Routing Engine (https://router.project-osrm.org)
/// 4. OpenStreetMap Overpass Live Automotive POI API (EV Chargers, Fuel, Tow/Repair, Car Rental)
/// 5. Open-Meteo Live Road Weather & Grip Telemetry (https://api.open-meteo.com)
/// 6. NHTSA vPIC + Live Recalls & Complaints (https://vpic.nhtsa.dot.gov & https://api.nhtsa.gov)
/// 7. US EPA FuelEconomy.gov Live Technical Specs (https://www.fueleconomy.gov)
class LiveApisService {
  static const Map<String, String> _headers = {
    'User-Agent': 'OtonomSuperApp/1.1.0 (https://github.com/CemilKorkmaz/otonom)',
    'Accept': 'application/json',
  };

  static const List<String> _overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  final Map<String, ApiEndpointStatus> statuses = {};

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

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

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
    } catch (_) {
      // Fallback to GeoJS IP geolocation below
    }

    // Fallback: GeoJS (from public-apis/public-apis -> Geocoding -> GeoJS, Auth: No)
    try {
      final res = await http
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
          return (point: pt, source: 'GeoJS Canlı IP Konumu ($city)');
        }
      }
    } catch (_) {}

    sw.stop();
    const istanbul = LatLng(40.9903, 29.0292); // Kadıköy fallback
    _recordStatus(
      id: 'gps',
      name: 'Konum Servisi',
      provider: 'Varsayılan Merkez',
      online: false,
      latencyMs: sw.elapsedMilliseconds,
      summary: 'Konum izni bekleniyor (Kadıköy/İstanbul)',
    );
    return (point: istanbul, source: 'İstanbul Merkez (GPS İzni Verin)');
  }

  /// 2A. Nominatim Reverse Geocoding (GPS -> Exact Open Street Address for 112 SOS)
  Future<String> reverseGeocodeAddress(LatLng point) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
      '&lat=${point.latitude}&lon=${point.longitude}&accept-language=tr',
    );
    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 7));
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
    } catch (_) {}
    sw.stop();
    _recordStatus(
      id: 'nominatim',
      name: 'Açık Adres (Nominatim)',
      provider: 'nominatim.openstreetmap.org',
      online: false,
      latencyMs: sw.elapsedMilliseconds,
      summary: 'Çevrimdışı koordinat modu',
    );
    return '${point.latitude.toStringAsFixed(5)}° K, ${point.longitude.toStringAsFixed(5)}° D';
  }

  /// 2B. Nominatim Forward Place Search (Type any destination in Turkey/World)
  Future<List<LivePlaceSearchResult>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=jsonv2'
      '&q=${Uri.encodeComponent(q)}&limit=6&accept-language=tr',
    );
    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
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
        _recordStatus(
          id: 'nominatim',
          name: 'Açık Adres & Arama (Nominatim)',
          provider: 'nominatim.openstreetmap.org',
          online: true,
          latencyMs: sw.elapsedMilliseconds,
          summary: '"$q" için ${results.length} gerçek konum bulundu',
        );
        return results;
      }
    } catch (_) {}
    sw.stop();
    return [];
  }

  /// 3. Project OSRM Live Road Route Calculation
  Future<LiveOsrmRoute?> fetchDrivingRoute(LatLng origin, LatLng destination) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );
    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 9));
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
          final legs = (first['legs'] as List<dynamic>?) ?? [];
          if (legs.isNotEmpty) {
            final steps =
                ((legs.first as Map<String, dynamic>)['steps'] as List<dynamic>?) ??
                    [];
            for (final s in steps.take(12)) {
              final sm = s as Map<String, dynamic>;
              final roadName = (sm['name']?.toString() ?? '').trim();
              final distM = ((sm['distance'] as num?)?.toDouble() ?? 0).round();
              if (roadName.isNotEmpty && distM > 50) {
                stepsOut.add('$roadName boyunca ${(distM / 1000).toStringAsFixed(1)} km ilerleyin');
              }
            }
          }

          final km = distMeters / 1000.0;
          final mins = (durSeconds / 60.0).round();
          _recordStatus(
            id: 'osrm',
            name: 'Canlı Yol Rotası (OSRM)',
            provider: 'router.project-osrm.org',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: '${km.toStringAsFixed(1)} km · $mins dk (${pts.length} yol noktası)',
          );
          return LiveOsrmRoute(
            polyline: pts,
            distanceKm: km,
            durationMinutes: mins,
            stepInstructions: stepsOut,
          );
        }
      }
    } catch (_) {}
    sw.stop();
    _recordStatus(
      id: 'osrm',
      name: 'Canlı Yol Rotası (OSRM)',
      provider: 'router.project-osrm.org',
      online: false,
      latencyMs: sw.elapsedMilliseconds,
      summary: 'Kuş uçuşu yedek rota aktif',
    );
    return null;
  }

  /// 4. OpenStreetMap Overpass Live Automotive POIs:
  ///    - 'ev' -> amenity=charging_station
  ///    - 'fuel' -> amenity=fuel
  ///    - 'tow_repair' -> shop=car_repair / craft=car_repair / roadside assistance
  ///    - 'car_rental' -> amenity=car_rental
  Future<List<LivePoiItem>> fetchNearbyAutomotivePois({
    required LatLng center,
    required String category,
    List<LatLng> sampleAlongPolyline = const [],
    int radiusMeters = 12000,
  }) async {
    final sw = Stopwatch()..start();

    // Build sample points (either around current location or 3 points along route!)
    final queryCenters = <LatLng>[center];
    if (sampleAlongPolyline.length >= 6) {
      queryCenters.add(sampleAlongPolyline[sampleAlongPolyline.length ~/ 3]);
      queryCenters.add(sampleAlongPolyline[(sampleAlongPolyline.length * 2) ~/ 3]);
    }

    String tagFilter;
    switch (category) {
      case 'ev':
        tagFilter = '["amenity"="charging_station"]';
        break;
      case 'fuel':
        tagFilter = '["amenity"="fuel"]';
        break;
      case 'tow_repair':
        tagFilter = '["shop"="car_repair"]';
        break;
      case 'car_rental':
        tagFilter = '["amenity"="car_rental"]';
        break;
      default:
        tagFilter = '["amenity"="fuel"]';
    }

    final aroundClauses = queryCenters
        .map(
          (pt) =>
              'nwr$tagFilter(around:$radiusMeters,${pt.latitude.toStringAsFixed(4)},${pt.longitude.toStringAsFixed(4)});',
        )
        .join('\n');

    final overpassQl = '''
[out:json][timeout:12];
(
$aroundClauses
);
out center 35;
''';

    for (final mirror in _overpassMirrors) {
      try {
        final res = await http
            .post(
              Uri.parse(mirror),
              headers: {
                ..._headers,
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              },
              body: 'data=${Uri.encodeQueryComponent(overpassQl)}',
            )
            .timeout(const Duration(seconds: 10));

        if (res.statusCode == 200) {
          sw.stop();
          final payload = jsonDecode(res.body) as Map<String, dynamic>;
          final elements = (payload['elements'] as List<dynamic>?) ?? [];
          final out = <LivePoiItem>[];
          final seenIds = <String>{};

          for (final raw in elements) {
            final el = raw as Map<String, dynamic>;
            final id = '${el['type']}_${el['id']}';
            if (seenIds.contains(id)) continue;
            seenIds.add(id);

            double? lat = (el['lat'] as num?)?.toDouble();
            double? lon = (el['lon'] as num?)?.toDouble();
            if (lat == null || lon == null) {
              final c = el['center'] as Map<String, dynamic>?;
              lat = (c?['lat'] as num?)?.toDouble();
              lon = (c?['lon'] as num?)?.toDouble();
            }
            if (lat == null || lon == null) continue;

            final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
            final rawName = (tags['name'] ??
                    tags['brand'] ??
                    tags['operator'] ??
                    _defaultPoiLabel(category))
                .toString()
                .trim();
            final brand =
                (tags['brand'] ?? tags['operator'] ?? rawName).toString().trim();
            final phone =
                (tags['phone'] ?? tags['contact:phone'] ?? tags['mobile'])
                    ?.toString()
                    .trim();
            final street = [
              tags['addr:street'],
              tags['addr:suburb'] ?? tags['addr:district'],
              tags['addr:city'],
            ].where((x) => x != null && x.toString().trim().isNotEmpty).join(', ');

            final pt = LatLng(lat, lon);
            final distKm = haversineKm(center, pt);

            final subtitle = _buildPoiSubtitle(category, tags, brand);
            final chipTags = _buildPoiTags(category, tags);

            out.add(
              LivePoiItem(
                id: id,
                name: rawName,
                brandOrOperator: brand,
                category: category,
                point: pt,
                distanceKm: distKm,
                phone: (phone != null && phone.isNotEmpty) ? phone : null,
                address: street.isNotEmpty ? street : null,
                subtitle: subtitle,
                tags: chipTags,
              ),
            );
          }

          out.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          _recordStatus(
            id: 'overpass_$category',
            name: 'Canlı Harita Noktaları ($category)',
            provider: 'OpenStreetMap Overpass API',
            online: true,
            latencyMs: sw.elapsedMilliseconds,
            summary: '${out.length} gerçek istasyon/işletme çekildi',
          );
          return out.take(25).toList();
        }
      } catch (_) {
        // Try next Overpass mirror
      }
    }

    sw.stop();
    _recordStatus(
      id: 'overpass_$category',
      name: 'Canlı Harita Noktaları ($category)',
      provider: 'OpenStreetMap Overpass API',
      online: false,
      latencyMs: sw.elapsedMilliseconds,
      summary: 'Sunucu yoğun — yerel katalog yedeği aktif',
    );
    return [];
  }

  String _defaultPoiLabel(String category) {
    switch (category) {
      case 'ev':
        return 'Elektrikli Şarj İstasyonu';
      case 'fuel':
        return 'Akaryakıt İstasyonu';
      case 'tow_repair':
        return 'Oto Servis & Yol Yardım';
      case 'car_rental':
        return 'Araç Kiralama Noktası';
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
      final cap = tags['capacity'] ?? tags['socket:type2'] ?? tags['socket:ccs'] ?? '2+';
      final output = tags['socket:ccs:output'] ??
          tags['charging_station:output'] ??
          tags['maxpower'] ??
          'AC/DC Hızlı Şarj';
      return '⚡ Operatör: $brand · Güç: $output · Kapasite: $cap Soket';
    }
    if (category == 'fuel') {
      final fuels = <String>[];
      if (tags['fuel:octane_95'] == 'yes' || tags['fuel:gasoline'] == 'yes') {
        fuels.add('Kurşunsuz 95');
      }
      if (tags['fuel:diesel'] == 'yes') fuels.add('Motorin');
      if (tags['fuel:lpg'] == 'yes') fuels.add('LPG');
      final fText = fuels.isEmpty ? 'Benzin & Motorin' : fuels.join(' · ');
      return '⛽ Marka: $brand · $fText';
    }
    if (category == 'tow_repair') {
      final service = tags['service'] ?? 'Mekanik, Kurtarma & Yol Yardım';
      return '🔧 $brand · Hizmet: $service';
    }
    final opening = tags['opening_hours'] ?? '08:00 - 22:00 / 7-24';
    return '🔑 $brand · Çalışma: $opening';
  }

  List<String> _buildPoiTags(String category, Map<String, dynamic> tags) {
    final res = <String>['Canlı OSM Verisi'];
    if (tags['opening_hours'] == '24/7') res.add('7/24 Açık');
    if (tags['wheelchair'] == 'yes') res.add('Engelli Uygun');
    if (tags['shop'] == 'convenience') res.add('Market');
    if (tags['car_wash'] == 'yes') res.add('Oto Yıkama');
    if (tags['socket:ccs'] != null) res.add('CCS2 DC');
    if (tags['socket:type2'] != null) res.add('Type 2 AC');
    if (tags['phone'] != null || tags['contact:phone'] != null) {
      res.add('Doğrudan Telefon Mevcut');
    }
    return res;
  }

  /// 5. Open-Meteo Live Road Weather & Grip Telemetry (Auth: No)
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
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 7));
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
              '❄️ Asfalt sıcaklığı kritik (${temp.toStringAsFixed(1)}°C): Gizli buzlanma riski ve EV batarya rejenerasyon düşüşü olabilir.';
        } else if (precip > 0.2 || code >= 51) {
          advisory =
              '🌧️ Islak zemin (${precip.toStringAsFixed(1)} mm): Takip mesafesini 2 katına çıkarın, ani şerit değişiminden kaçının.';
        } else if (wind >= 38) {
          advisory =
              '💨 Kuvvetli yan rüzgâr (${wind.toStringAsFixed(0)} km/s): Köprü ve viyadük geçişlerinde direksiyon hakimiyetine dikkat edin.';
        } else {
          advisory =
              '✅ Kuru ve ideal sürüş zemini (${temp.toStringAsFixed(1)}°C · Rüzgâr ${wind.toStringAsFixed(0)} km/s).';
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
    } catch (_) {}
    sw.stop();
    return null;
  }

  String _weatherCodeTr(int code) {
    if (code == 0) return 'Açık Güneşli / Net Görüş';
    if (code <= 3) return 'Parçalı Bulutlu';
    if (code == 45 || code == 48) return 'Sisli (Görüş Düşük)';
    if (code >= 51 && code <= 67) return 'Yağmurlu';
    if (code >= 71 && code <= 77) return 'Kar Yağışlı';
    if (code >= 80 && code <= 82) return 'Sağanak Yağışlı';
    if (code >= 95) return 'Fırtına / Gök Gürültülü';
    return 'Normal Yol Koşulu';
  }

  /// 6A. NHTSA vPIC Live Models for Any Brand + Year
  Future<List<String>> fetchNhtsaModelsForMakeYear({
    required String make,
    required String year,
  }) async {
    final sw = Stopwatch()..start();
    final uri = Uri.parse(
      'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/'
      '${Uri.encodeComponent(make.trim())}/modelyear/${Uri.encodeComponent(year.trim())}?format=json',
    );
    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      sw.stop();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final results = (data['Results'] as List<dynamic>?) ?? [];
        final models = results
            .map((e) => (e as Map<String, dynamic>)['Model_Name']?.toString() ?? '')
            .where((s) => s.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        _recordStatus(
          id: 'nhtsa_vpic',
          name: 'Global Araç Katalog API (NHTSA)',
          provider: 'vpic.nhtsa.dot.gov',
          online: true,
          latencyMs: sw.elapsedMilliseconds,
          summary: '$year $make için ${models.length} resmi model çekildi',
        );
        return models;
      }
    } catch (_) {}
    sw.stop();
    return [];
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

    final recallUri = Uri.parse(
      'https://api.nhtsa.gov/recalls/recallsByVehicle'
      '?make=${Uri.encodeQueryComponent(make)}'
      '&model=${Uri.encodeQueryComponent(model)}'
      '&modelYear=${Uri.encodeQueryComponent(year)}',
    );
    final complaintUri = Uri.parse(
      'https://api.nhtsa.gov/complaints/complaintsByVehicle'
      '?make=${Uri.encodeQueryComponent(make)}'
      '&model=${Uri.encodeQueryComponent(model)}'
      '&modelYear=${Uri.encodeQueryComponent(year)}',
    );

    try {
      final responses = await Future.wait([
        http.get(recallUri, headers: _headers).timeout(const Duration(seconds: 8)),
        http.get(complaintUri, headers: _headers).timeout(const Duration(seconds: 8)),
      ]);
      sw.stop();

      if (responses[0].statusCode == 200) {
        final rData = jsonDecode(responses[0].body) as Map<String, dynamic>;
        final rList = (rData['results'] as List<dynamic>?) ?? [];
        for (final item in rList.take(8)) {
          final m = item as Map<String, dynamic>;
          recallsOut.add(
            LiveRecallItem(
              campaignNumber: m['NHTSACampaignNumber']?.toString() ?? '-',
              component: m['Component']?.toString() ?? 'Genel Donanım',
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
        for (final item in cList.take(10)) {
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
            '${recallsOut.length} geri çağırma · ${complaintsOut.length} kullanıcı raporu',
      );
    } catch (_) {
      sw.stop();
    }

    return (recalls: recallsOut, complaints: complaintsOut);
  }

  /// 7. US EPA FuelEconomy.gov Live Technical & Consumption Specs
  Future<List<LiveEpaVehicleSpec>> fetchEpaVehicleSpecs({
    required String year,
    required String make,
    required String model,
  }) async {
    final sw = Stopwatch()..start();
    final optionsUri = Uri.parse(
      'https://www.fueleconomy.gov/ws/rest/vehicle/menu/options'
      '?year=${Uri.encodeQueryComponent(year)}'
      '&make=${Uri.encodeQueryComponent(make)}'
      '&model=${Uri.encodeQueryComponent(model)}',
    );

    try {
      final optRes = await http
          .get(optionsUri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (optRes.statusCode != 200) {
        sw.stop();
        return [];
      }
      final optJson = jsonDecode(optRes.body);
      final rawItems = _extractMenuItems(optJson);
      final specs = <LiveEpaVehicleSpec>[];

      for (final item in rawItems.take(4)) {
        final vehicleId = item['value']?.toString() ?? '';
        final trimText = item['text']?.toString() ?? '';
        if (vehicleId.isEmpty) continue;

        final detailRes = await http
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
            // combE is kWh per 100 miles -> convert to kWh / 100 km (* 0.621371)
            combLabel = '${(combKwh * 0.621371).toStringAsFixed(1)} kWh/100km';
            cityLabel = combLabel;
            hwyLabel = combLabel;
          } else if (combMpg > 0) {
            // Convert US MPG to L/100km (235.215 / mpg)
            combLabel = '${(235.215 / combMpg).toStringAsFixed(1)} L/100km';
            cityLabel = cityMpg > 0
                ? '${(235.215 / cityMpg).toStringAsFixed(1)} L/100km'
                : '-';
            hwyLabel = hwyMpg > 0
                ? '${(235.215 / hwyMpg).toStringAsFixed(1)} L/100km'
                : '-';
          }

          final co2PerMile = double.tryParse(v['co2TailpipeGpm']?.toString() ?? '');
          final co2Km = co2PerMile != null
              ? '${(co2PerMile * 0.621371).round()} g/km'
              : '0 g/km (Sıfır Emisyon)';

          specs.add(
            LiveEpaVehicleSpec(
              id: vehicleId,
              make: v['make']?.toString() ?? make,
              model: v['model']?.toString() ?? model,
              year: v['year']?.toString() ?? year,
              trimDescription: trimText,
              cylinders: v['cylinders']?.toString() ?? (isEv ? 'Elektrik Motoru' : '-'),
              displacementL:
                  v['displ'] != null ? '${v['displ']} Litre' : (isEv ? 'BEV Batarya' : '-'),
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

      sw.stop();
      _recordStatus(
        id: 'epa_fueleconomy',
        name: 'Fabrika Tüketim & Motor Verisi (EPA)',
        provider: 'fueleconomy.gov',
        online: true,
        latencyMs: sw.elapsedMilliseconds,
        summary: '${specs.length} donanım paketi verisi çekildi',
      );
      return specs;
    } catch (_) {
      sw.stop();
      return [];
    }
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
