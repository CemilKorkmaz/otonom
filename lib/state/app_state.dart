import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/world_brands_engineering.dart';
import '../models/brand_theme_config.dart';
import '../models/live_api_models.dart';
import '../models/user_garage_vehicle.dart';
import '../services/dynamic_icon_service.dart';
import '../services/live_apis_service.dart';

class OtonomAppState extends ChangeNotifier {
  final LiveApisService liveApis = LiveApisService();

  // Personal Garage (starts completely clean — no hardcoded sample cars!)
  final List<UserGarageVehicle> _garageVehicles = [];
  String? _activeGarageVehicleId;

  // Cached Deep Encyclopedia Dossier for the user's active car
  LiveWikipediaVehicleSummary? _activeWikiSummary;
  List<LiveEpaVehicleSpec> _activeEpaSpecs = [];
  List<LiveRecallItem> _activeRecalls = [];
  List<LiveComplaintItem> _activeComplaints = [];
  bool _isLoadingEncyclopediaDossier = false;

  // Live Geolocation, Weather, Routing & Unified POIs
  LatLng _currentLocation = const LatLng(40.9903, 29.0292);
  String _locationSource = 'Başlatılıyor...';
  String _liveStreetAddress = 'Canlı adres çözümleniyor...';
  LiveRoadWeather? _liveWeather;

  LatLng _destinationPoint = const LatLng(40.7654, 29.9408);
  String _destinationName = 'Kocaeli / Sapanca Otoyol Aksı';
  LiveOsrmRoute? _liveRoute;

  List<LivePoiItem> _liveEvStations = [];
  List<LivePoiItem> _liveFuelStations = [];
  List<LivePoiItem> _liveTowRepairs = [];
  List<LivePoiItem> _liveRentalPlaces = [];
  final Set<String> _addedWaypointStationIds = {};
  bool _isLoadingLive = false;
  bool _darkMapTiles = true;

  String _driverName = '';
  String _userPlate = '';
  String _bloodType = 'A Rh (+)';
  String _emergencyContact = '';
  int _currentSocOrFuelPercent = 80;

  List<UserGarageVehicle> get garageVehicles =>
      List.unmodifiable(_garageVehicles);

  UserGarageVehicle? get activeGarageVehicle {
    if (_garageVehicles.isEmpty) return null;
    if (_activeGarageVehicleId != null) {
      for (final v in _garageVehicles) {
        if (v.id == _activeGarageVehicleId) return v;
      }
    }
    return _garageVehicles.first;
  }

  BrandThemeConfig get brandTheme =>
      WorldBrandsEngineering.buildThemeForVehicle(activeGarageVehicle);

  bool get isElectricVehicle =>
      activeGarageVehicle?.powertrain.isElectric ?? false;

  String get activeVehicleTitle =>
      activeGarageVehicle?.fullTitle ?? 'Garajım’dan Kendi Aracınızı Ekleyin';

  String get activeVehicleSubtitle => activeGarageVehicle != null
      ? '${activeGarageVehicle!.powertrain.labelTr}${activeGarageVehicle!.plate.isNotEmpty ? " · ${activeGarageVehicle!.plate}" : ""}'
      : 'Dünya üzerindeki herhangi bir aracı ekleyebilirsiniz';

  LiveWikipediaVehicleSummary? get activeWikiSummary => _activeWikiSummary;
  List<LiveEpaVehicleSpec> get activeEpaSpecs => _activeEpaSpecs;
  List<LiveRecallItem> get activeRecalls => _activeRecalls;
  List<LiveComplaintItem> get activeComplaints => _activeComplaints;
  bool get isLoadingEncyclopediaDossier => _isLoadingEncyclopediaDossier;

  LatLng get currentLocation => _currentLocation;
  String get locationSource => _locationSource;
  String get liveStreetAddress => _liveStreetAddress;
  LiveRoadWeather? get liveWeather => _liveWeather;
  LatLng get destinationPoint => _destinationPoint;
  String get destinationName => _destinationName;
  LiveOsrmRoute? get liveRoute => _liveRoute;

  List<LivePoiItem> get liveRouteStations =>
      isElectricVehicle ? _liveEvStations : _liveFuelStations;

  List<LivePoiItem> get liveEvStations => _liveEvStations;
  List<LivePoiItem> get liveFuelStations => _liveFuelStations;
  List<LivePoiItem> get liveTowRepairs => _liveTowRepairs;
  List<LivePoiItem> get liveRentalPlaces => _liveRentalPlaces;
  Set<String> get addedWaypointStationIds => _addedWaypointStationIds;
  bool get isLoadingLive => _isLoadingLive;
  bool get darkMapTiles => _darkMapTiles;

  String get driverName => _driverName.isEmpty ? 'Sürücü' : _driverName;
  String get userPlate => activeGarageVehicle?.plate.isNotEmpty == true
      ? activeGarageVehicle!.plate
      : (_userPlate.isEmpty ? 'Belirtilmedi' : _userPlate);
  String get bloodType => _bloodType;
  String get emergencyContact => _emergencyContact;
  int get currentSocOrFuelPercent => _currentSocOrFuelPercent;

  int get onlineApiCount =>
      liveApis.statuses.values.where((s) => s.online).length;

  Future<void> loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getString('user_garage_vehicles_v2');
      if (rawList != null && rawList.isNotEmpty) {
        final decoded = jsonDecode(rawList) as List<dynamic>;
        _garageVehicles
          ..clear()
          ..addAll(
            decoded.map(
              (e) => UserGarageVehicle.fromJson(e as Map<String, dynamic>),
            ),
          );
      }
      _activeGarageVehicleId = prefs.getString('active_garage_vehicle_id_v2');
      _driverName = prefs.getString('driver_name') ?? '';
      _userPlate = prefs.getString('user_plate') ?? '';
      _bloodType = prefs.getString('blood_type') ?? 'A Rh (+)';
      _emergencyContact = prefs.getString('emergency_contact') ?? '';
      notifyListeners();

      if (activeGarageVehicle != null) {
        await refreshActiveVehicleEncyclopediaDossier();
      }
    } catch (_) {}
  }

  Future<void> _persistGarage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_garageVehicles.map((v) => v.toJson()).toList());
      await prefs.setString('user_garage_vehicles_v2', encoded);
      if (_activeGarageVehicleId != null) {
        await prefs.setString(
          'active_garage_vehicle_id_v2',
          _activeGarageVehicleId!,
        );
      } else {
        await prefs.remove('active_garage_vehicle_id_v2');
      }
    } catch (_) {}
  }

  Future<void> addGarageVehicle(UserGarageVehicle vehicle) async {
    _garageVehicles.insert(0, vehicle);
    _activeGarageVehicleId = vehicle.id;
    notifyListeners();

    await _persistGarage();
    await DynamicIconService.setBrandAppIcon(brandTheme.dynamicIconKey);
    await refreshActiveVehicleEncyclopediaDossier();
  }

  Future<void> selectActiveGarageVehicle(String id) async {
    _activeGarageVehicleId = id;
    _addedWaypointStationIds.clear();
    notifyListeners();

    await _persistGarage();
    await DynamicIconService.setBrandAppIcon(brandTheme.dynamicIconKey);
    await refreshActiveVehicleEncyclopediaDossier();
  }

  Future<void> removeGarageVehicle(String id) async {
    _garageVehicles.removeWhere((v) => v.id == id);
    if (_activeGarageVehicleId == id) {
      _activeGarageVehicleId =
          _garageVehicles.isNotEmpty ? _garageVehicles.first.id : null;
    }
    if (_garageVehicles.isEmpty) {
      _activeWikiSummary = null;
      _activeEpaSpecs = [];
      _activeRecalls = [];
      _activeComplaints = [];
    }
    notifyListeners();
    await _persistGarage();
    if (activeGarageVehicle != null) {
      await refreshActiveVehicleEncyclopediaDossier();
    }
  }

  /// Pulls live Wikipedia photo/history, EPA specs, NHTSA recalls & complaints for the active car!
  Future<void> refreshActiveVehicleEncyclopediaDossier([
    UserGarageVehicle? customTarget,
  ]) async {
    final v = customTarget ?? activeGarageVehicle;
    if (v == null) return;

    _isLoadingEncyclopediaDossier = true;
    notifyListeners();

    try {
      final yearStr = v.year.toString();
      final results = await Future.wait([
        liveApis.fetchVehicleWikipediaSummary(make: v.make, model: v.model),
        liveApis.fetchEpaVehicleSpecs(
          year: yearStr,
          make: v.make,
          model: v.model,
        ),
        liveApis.fetchRecallsAndComplaints(
          make: v.make,
          model: v.model,
          year: yearStr,
        ),
      ]);

      _activeWikiSummary = results[0] as LiveWikipediaVehicleSummary?;
      _activeEpaSpecs = results[1] as List<LiveEpaVehicleSpec>;
      final safety = results[2]
          as ({List<LiveRecallItem> recalls, List<LiveComplaintItem> complaints});
      _activeRecalls = safety.recalls;
      _activeComplaints = safety.complaints;
    } catch (_) {
    } finally {
      _isLoadingEncyclopediaDossier = false;
      notifyListeners();
    }
  }

  /// Connects to GPS/GeoJS, Nominatim, Open-Meteo, OSRM & Unified Overpass+Photon POIs!
  Future<void> refreshAllLiveApis() async {
    if (_isLoadingLive) return;
    _isLoadingLive = true;
    notifyListeners();

    try {
      final loc = await liveApis.resolveCurrentLocation();
      _currentLocation = loc.point;
      _locationSource = loc.source;
      notifyListeners();

      final results = await Future.wait([
        liveApis.reverseGeocodeAddress(_currentLocation),
        liveApis.fetchRoadWeather(_currentLocation),
        liveApis.fetchDrivingRoute(_currentLocation, _destinationPoint),
      ]);
      _liveStreetAddress = results[0] as String;
      _liveWeather = results[1] as LiveRoadWeather?;
      _liveRoute = results[2] as LiveOsrmRoute?;
      notifyListeners();

      final unified = await liveApis.fetchAllAutomotivePoisUnified(
        center: _currentLocation,
        routePolyline: _liveRoute?.polyline ?? const [],
      );
      _liveEvStations = unified.evStations;
      _liveFuelStations = unified.fuelStations;
      _liveTowRepairs = unified.towRepairs;
      _liveRentalPlaces = unified.carRentals;
    } catch (_) {
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  Future<void> setLiveDestination(LivePlaceSearchResult dest) async {
    _destinationPoint = dest.point;
    _destinationName = dest.shortName;
    _isLoadingLive = true;
    notifyListeners();

    try {
      _liveRoute =
          await liveApis.fetchDrivingRoute(_currentLocation, _destinationPoint);
      final unified = await liveApis.fetchAllAutomotivePoisUnified(
        center: _currentLocation,
        routePolyline: _liveRoute?.polyline ?? const [],
      );
      _liveEvStations = unified.evStations;
      _liveFuelStations = unified.fuelStations;
    } finally {
      _isLoadingLive = false;
      notifyListeners();
    }
  }

  void toggleMapTileStyle() {
    _darkMapTiles = !_darkMapTiles;
    notifyListeners();
  }

  Future<void> updateEmergencyProfile({
    required String driverName,
    required String plate,
    required String bloodType,
    required String emergencyContact,
  }) async {
    _driverName = driverName;
    _userPlate = plate;
    _bloodType = bloodType;
    _emergencyContact = emergencyContact;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_name', driverName);
      await prefs.setString('user_plate', plate);
      await prefs.setString('blood_type', bloodType);
      await prefs.setString('emergency_contact', emergencyContact);
    } catch (_) {}
  }

  void updateSocOrFuelPercent(int value) {
    _currentSocOrFuelPercent = value.clamp(5, 100);
    notifyListeners();
  }
}
